#!/usr/bin/env python3
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import argparse
import ast
import base64
import json
import re
import subprocess
import sys
import tempfile

from pathlib import Path


def print_info(pargs, msg):
    if pargs.gha_console:
        print(f"::notice::{msg}")
    else:
        print(f"info: {msg}")


def print_warning(pargs, msg):
    if pargs.gha_console:
        print(f"::warning::{msg}")
    else:
        print(f"warning: {msg}")


def print_error(pargs, msg):
    if pargs.gha_console:
        print(f"::error::{msg}")
    else:
        print(f"error: {msg}")


def print_debug(pargs, msg):
    if not msg or pargs.verbose < 1:
        return
    if pargs.gha_console:
        print(f"::debug::{msg}")
    else:
        print(f"debug: {msg}")


def print_group(pargs, name, content):
    if not content:
        return
    if pargs.gha_console:
        print(f"::group::{name}")
        print(content)
        print("::endgroup::")
    else:
        print(f"==== {name} ====")
        print(content)
        print("===============")


def parse_json(pargs, asset_msg, json_str):
    try:
        return json.loads(json_str)
    except Exception as e:
        print_error(pargs, f"cannot parse JSON of {asset_msg}")
        print_group(pargs, "error", e)
        print_group(pargs, "content info", json_str)
        sys.exit(1)


def modify_extension_bzl(pargs, extension_bzl, archives, keep_entries=None):
    extension_ast = ast.parse(extension_bzl)
    # Look for an assignment to '_ARCHIVES'
    archives_assign = None
    for stmt in extension_ast.body:
        if isinstance(stmt, ast.Assign) and len(stmt.targets) == 1 and stmt.targets[0].id == '_ARCHIVES':  # noqa:E501
            archives_assign = stmt
    if not archives_assign:
        print_error(pargs, "could not find assignement to _ARCHIVES in extension.bzl")
        sys.exit(1)

    # If we want to keep some entries, we need to evaluate the original dictionary.
    if keep_entries:
        # Evaluate the original dictionary.
        if not isinstance(archives_assign.value, ast.Dict):
            print_error("Cannot update _ARCHIVES in extension.bzl: a dictionary was expected")
            sys.exit(1)
        # Note that `literal_eval` is safe, it will not execute any python code. The downside
        # is that it only works for constants expressions but we know this is the case since
        # the content of _ARCHIVES was generated in the presign step.
        try:
            old_archives = ast.literal_eval(archives_assign.value)
        except Exception as e:
            print_error(pargs, "cannot parse _ARCHIVES in extension.bzl")
            print_group(pargs, "error", e)
            print_group(
                pargs, "content",
                "\n".join(extension_bzl[archives_assign.lineno - 1:archives_assign.end_lineno])
            )
            sys.exit(1)

        old_archives = {key: val for (key, val) in old_archives.items() if key in keep_entries}
        archives = old_archives | archives

    # Use the AST info to remove the old assignment and create a new one.
    extension_bzl = extension_bzl.splitlines(True)
    extension_bzl[archives_assign.lineno - 1:archives_assign.end_lineno] = \
        "_ARCHIVES = " + json.dumps(archives, indent="    ") + "\n"

    return ''.join(extension_bzl)


def modify_workflow_release(pargs, workflow_release, anchors):
    anchors = anchors.copy()
    workflow_release = workflow_release.splitlines(True)
    # Create a regex to search and edit anchors. # We look for lines of the form:
    # <spaces>default: <value> # <<< ANCHOR >>>
    anchor_re = re.compile(r"\s*default: (.*) # <<< (.*) >>>\s*\n")
    # Look for the anchors, not super efficient but there will be only a small number of them.
    for (i, line) in enumerate(workflow_release):
        res = anchor_re.fullmatch(line)
        if not res:
            continue
        value = anchors.pop(res.group(2), None)
        if not value:
            # Ignore anchors not in the dictionary.
            continue
        # Edit the value
        workflow_release[i] = line[:res.start(1)] + value + line[res.end(1):]

    # Make sure anchors were found.
    if anchors:
        print_error(pargs, "The following anchors were not found: {}".format(
            ','.join(anchors.keys())
        ))
        sys.exit(1)

    return ''.join(workflow_release)


def run_or_exit(pargs, msg, *args, **kwargs):
    kwargs["capture_output"] = True
    print_debug(pargs, f"running: {args}")
    res = subprocess.run(
        *args,
        **kwargs,
    )
    print_debug(pargs, f"return code is {res.returncode}")
    print_debug(pargs, res.stderr.decode(errors='replace'))
    if res.returncode != 0:
        print_error(pargs, msg)
        print_group(pargs, "stderr", res.stderr.decode(errors='replace'))
        sys.exit(1)
    return res.stdout


def run_gh_or_exit(pargs, msg, cmd):
    pre_cmd = [pargs.gh_bin]
    if pargs.release_repo:
        pre_cmd.extend(["-R", pargs.release_repo])
    return run_or_exit(pargs, msg, pre_cmd + cmd, cwd=pargs.ot_sku_repo)


def get_release_info(pargs, tag):
    # Get asset information so that we can update the archives in the extension.
    release_info = run_gh_or_exit(pargs, "cannot query release assets", [
        "release", "view", tag, "--json", "assets,targetCommitish,url"])
    return parse_json(pargs, "release asset", release_info)


def target_commitish_to_sha(pargs, commitish):
    return run_or_exit(
        pargs,
        "cannot retrieve release target SHA",
        [pargs.gh_bin, "api", "-H", "Accept: application/vnd.github.sha",
         f"repos/{pargs.release_repo}/commits/{commitish}"],
    ).decode('utf-8').strip()


def create_ref(pargs, msg_type, sha, ref):
    run_or_exit(
        pargs,
        f"cannot create {msg_type} on github",
        [pargs.gh_bin, "api", "--method", "POST",
         f"repos/{pargs.release_repo}/git/refs",
         "-f", f"ref={ref}",
         "-f", f'sha={sha}'],
    )


def create_branch(pargs, branch_sha, branch_name):
    create_ref(pargs, f"branch {branch_name}", branch_sha, f"refs/heads/{branch_name}")


def get_file_content(pargs, ref, filename):
    file_info = run_or_exit(
        pargs,
        f"cannot retrieve the content of {filename}",
        [pargs.gh_bin, "api",
         f"repos/{pargs.release_repo}/contents/{filename}?ref={ref}"],
    ).decode('utf-8')
    return parse_json(pargs, "file info", file_info)


def push_commit(pargs, branch_name, commit_msg, file_info, content):
    filename = file_info["path"]
    run_or_exit(
        pargs,
        f"cannot push commit to branch {branch_name} on github",
        [pargs.gh_bin, "api", "--method", "PUT",
         f"repos/{pargs.release_repo}/contents/{filename}",
         "-f", f"message={commit_msg}",
         "-f", f"branch={branch_name}",
         "-f", "sha={}".format(file_info["sha"]),
         "-f", b"content=" + base64.b64encode(content),
         ],
    )


def create_pr(pargs, head, base, title, body):
    pr_info = run_or_exit(
        pargs,
        "cannot create pull request on github",
        [pargs.gh_bin, "api", "--method", "POST",
         "-H", "Accept: application/vnd.github+json",
         f"repos/{pargs.release_repo}/pulls",
         "-f", f"title={title}",
         "-f", f"head={head}",
         "-f", f"base={base}",
         "-f", f"body={body}",
         ],
    )
    return parse_json(pargs, "pr info", pr_info)


def download_asset(pargs, asset_info):
    asset = run_or_exit(
        pargs,
        "cannot retrieve asset",
        [pargs.gh_bin, "api", "-H", "Accept: application/octet-stream",
         asset_info["url"]]
    )
    # TODO verify hash?
    return asset


def asset_name_match(candidate_name, asset_name_constraint):
    asset_name, allowed_exts = asset_name_constraint
    for ext in allowed_exts:
        if candidate_name.endswith(ext) and candidate_name.removesuffix(ext) == asset_name:
            return True
    return False


def get_release_asset_info(pargs, release_info, asset_names, allow_no_match=False):
    res = {}
    for (key, asset_name) in asset_names.items():
        assets = [
            asset
            for asset in release_info["assets"]
            if asset_name_match(asset["name"], asset_name)
        ]
        if len(assets) == 0:
            if allow_no_match:
                # Skip this item
                continue
            print_error(pargs, f"no asset matching {asset_name} in release {pargs.tag}")
            sys.exit(1)
        if len(assets) > 1:
            print_error(pargs, f"more than one asset matching {asset_name} in release {pargs.tag}")
            sys.exit(1)
        asset_info = run_or_exit(
            pargs,
            "cannot query asset info",
            [pargs.gh_bin, "api", assets[0]["apiUrl"]]
        )
        res[key] = parse_json(pargs, "release asset", asset_info)
    return res


def decode_github_integrity(digest):
    # FIXME The digest format of Github does not seem to be documented.
    # Experimentally, it seems to be 'sha256:<hash>'
    assert digest.startswith('sha256:'), 'release asset digest does not use SHA256'
    return {
        'sha256': digest.removeprefix('sha256:')
    }


def check_repo_clean(pargs, repo_name, repo_path):
    # Make sure that git repository is clean.
    run_or_exit(
        pargs,
        f"cannot create a release because the {repo_name} repository is not clean",
        ["git", "diff-index", "--exit-code", "HEAD"],
        cwd=repo_path,
    )


def get_repo_head(pargs, repo_path):
    return run_or_exit(
        pargs,
        f"cannot parse HEAD in repository {repo_path}",
        ["git", "rev-parse", "HEAD"],
        cwd=repo_path,
    ).decode('utf-8').strip()


def cquery_path(pargs, label):
    output = run_or_exit(
        pargs,
        "bazel cquery failed",
        [pargs.bazelisk, "cquery", "--output=files"] + pargs.bazel_opts + [label],
        cwd=pargs.ot_repo,
    ).decode('utf-8').splitlines()
    if len(output) != 1:
        print_error(pargs, "bazel cquery output has unexpected format:")
        print_group(pargs, "cquery output", output)
        sys.exit(1)
    return (pargs.ot_repo / Path(output[0])).resolve()


ARCHIVES_EXTENSIONS = [
    ".zip", ".tar.xz",
]


ARTIFACTS = {
    "perso": {
        "presign_label": "@provisioning_exts//open/perso:presign_perso",
        "presign_name": ("presign_perso", ARCHIVES_EXTENSIONS),
        "presign_ext_repo": "presign_perso",
        "sig_test_label": "@provisioning_exts//open/perso:signature_test",
        "release_label": "@provisioning_exts//open/perso:perso_release",
        "release_name": ("perso_release", ARCHIVES_EXTENSIONS),
        "release_ext_repo": "perso_release",
    },
    "rom_ext": {
        "presign_label": "@provisioning_exts//open/rom_ext:presign_rom_ext",
        "presign_name": ("presign_rom_ext", ARCHIVES_EXTENSIONS),
        "presign_ext_repo": "presign_rom_ext",
        "sig_test_label": "@provisioning_exts//open/rom_ext:signature_test",
        "release_label": "@provisioning_exts//open/rom_ext:rom_ext_release",
        "release_name": ("rom_ext_release", ARCHIVES_EXTENSIONS),
        "release_ext_repo": "rom_ext_release",
    },
}


def run_buildifier_on(pargs, file_content):
    # Builidifier only runs on files so we need to create a temporary file.
    with tempfile.NamedTemporaryFile(suffix=".bzl") as f:
        f.write(file_content)
        f.flush()
        run_or_exit(
            pargs,
            "cannot format file using buildifier",
            [pargs.bazel_bin, "run", "--",
             "@buildifier_prebuilt//:buildifier",
             f.name],
            cwd=pargs.ot_sku_repo,
        )
        f.seek(0)
        return f.read()


def create_presign_release(pargs):
    artifact_labels = [
        ARTIFACTS[art]["presign_label"]
        for art in pargs.release_artifacts
    ]
    # Build the artifacts.
    run_or_exit(pargs, "cannot build provisioning artifacts", [
        pargs.bazelisk, "build"] + pargs.bazel_opts + [
        "--stamp"] + artifact_labels,
        cwd=pargs.ot_repo,
    )

    # Obtain absolute paths to the artefacts.
    binaries = [cquery_path(pargs, label) for label in artifact_labels]

    # Obtain the hash of the current HEAD so that we can tag it.
    cur_head = get_repo_head(pargs, pargs.ot_sku_repo)

    # Create release.
    default_release_notes = "This is a presigning release of the following artifacts: {}".format(
        ",".join(pargs.release_artifacts)
    )
    run_gh_or_exit(pargs, "cannot create release", [
        "release",
        "create",
        # Pre-release.
        "-p",
        # Use tag as release notes if none is provided.
        "-n", pargs.release_notes or default_release_notes,
        # Use tag as title if none is provided.
        "-t", pargs.release_title or pargs.tag,
        # Target the commit at which we did the build.
        "--target", cur_head,
        # Release tag
        pargs.tag,
    ] + binaries,  # Binaries to release
    )


def create_presign_branch(pargs):
    # Important note:
    # this entire function is written in such a way that it does not need git
    # access. It only requires access the github API through `gh`.

    # Get asset information so that we can update the archives in the extension.
    release_info = get_release_info(pargs, pargs.tag)

    # Convert release target into a SHA.
    release_sha = target_commitish_to_sha(pargs, release_info["targetCommitish"])

    # Get asset information.
    artifact_info = get_release_asset_info(
        pargs, release_info, {
            ARTIFACTS[art]["presign_ext_repo"]: ARTIFACTS[art]["presign_name"]
            for art in pargs.release_artifacts
        }
    )

    # Get the content of the original extension file.
    orig_extension_bzl = get_file_content(pargs, release_sha, "extension.bzl")

    # Generate a modified extension file.
    new_extension_bzl = modify_extension_bzl(
        pargs,
        base64.b64decode(orig_extension_bzl["content"]).decode('utf-8'),
        {
            repo: {
                "url": art_info["browser_download_url"],
            } | decode_github_integrity(art_info['digest'])
            for (repo, art_info) in artifact_info.items()
        }
    ).encode('utf-8')

    # Run buildifier to make sure that it is formatted properly.
    new_extension_bzl = run_buildifier_on(
        pargs,
        new_extension_bzl
    )

    # Create a release branch.
    create_branch(pargs, release_sha, pargs.release_branch)

    # Push a commit to the branch.
    push_commit(
        pargs, pargs.release_branch,
        f"Update archives for presigning release {pargs.tag}",
        orig_extension_bzl, new_extension_bzl
    )

    # If we do not need to edit the workflow file, stop here.
    if not pargs.edit_workflow:
        return
    # Get the content of the original release flow.
    orig_workflow_release = get_file_content(pargs, release_sha, ".github/workflows/release.yml")
    # Generate a workflow file.
    new_workflow = modify_workflow_release(
        pargs,
        base64.b64decode(orig_workflow_release["content"]).decode('utf-8'),
        pargs.edit_workflow
    ).encode('utf-8')

    # Push a commit to the branch.
    push_commit(
        pargs, pargs.release_branch,
        "Prepare release flow for post-signing",
        orig_workflow_release, new_workflow
    )


def create_postsign_release(pargs):
    # Obtain the hash of the current HEAD so that we can tag it.
    cur_head = get_repo_head(pargs, pargs.ot_sku_repo)
    branch_head = target_commitish_to_sha(pargs, f"heads/{pargs.release_branch}")

    if cur_head != branch_head:
        print_warning(
            pargs,
            f"The ot-sku HEAD ({cur_head}) differs from the release branch head ({branch_head})"
        )

    # Run a signature test check.
    run_or_exit(pargs, "cannot verify the signatures", [
        pargs.bazelisk, "test"] + pargs.bazel_opts + [
        "--test_output=streamed"] + [
            ARTIFACTS[art]["sig_test_label"] for art in pargs.release_artifacts],
        cwd=pargs.ot_repo,
    )

    artifact_labels = [
        ARTIFACTS[art]["release_label"]
        for art in pargs.release_artifacts
    ]
    # Build the artifacts.
    run_or_exit(pargs, "cannot build release artifacts", [
        pargs.bazelisk, "build"] + pargs.bazel_opts + [
        "--stamp"] + artifact_labels,
        cwd=pargs.ot_repo,
    )

    # Obtain absolute paths to the artefacts.
    binaries = [cquery_path(pargs, label) for label in artifact_labels]

    # Create release.
    run_gh_or_exit(pargs, "cannot create release", [
        "release",
        "create",
        # Pre-release.
        "-p",
        # Use tag as release notes if none is provided.
        "-n", pargs.release_notes or pargs.tag,
        # Use tag as title if none is provided.
        "-t", pargs.release_title or pargs.tag,
        # Target the commit at which we did the build.
        "--target", cur_head,
        # Release tag
        pargs.tag,
    ] + binaries,  # Binaries to release
    )


def update_postsign_branch(pargs):
    # Important note:
    # this entire function is written in such a way that it does not need git
    # access. It only requires access the github API through `gh`.

    # Get asset information so that we can update the archives in the extension.
    release_info = get_release_info(pargs, pargs.tag)

    # Get the SHA of the release branch.
    release_branch_sha = target_commitish_to_sha(pargs, pargs.release_branch)

    # Get asset information.
    artifact_info = get_release_asset_info(
        pargs, release_info, {
            ARTIFACTS[art]["release_ext_repo"]: ARTIFACTS[art]["release_name"]
            for art in pargs.release_artifacts
        },
    )

    # Get the content of the original extension file.
    orig_extension_bzl = get_file_content(pargs, release_branch_sha, "extension.bzl")

    # Generate a modified extension file.
    new_extension_bzl = modify_extension_bzl(
        pargs,
        base64.b64decode(orig_extension_bzl["content"]).decode('utf-8'),
        {
            repo: {
                "url": art_info["browser_download_url"],
            } | decode_github_integrity(art_info['digest'])
            for (repo, art_info) in artifact_info.items()
        },
        # Keep the original presign entries (which points to the BUILD
        # release and not the final release).
        keep_entries=[
            ARTIFACTS[art]["presign_ext_repo"]
            for art in pargs.release_artifacts
        ]
    ).encode('utf-8')

    # Run buildifier to make sure that it is formatted properly.
    new_extension_bzl = run_buildifier_on(
        pargs,
        new_extension_bzl
    )

    # Push a commit to the branch.
    push_commit(
        pargs, pargs.release_branch,
        "Update archives for release",
        orig_extension_bzl, new_extension_bzl
    )


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--gh-bin',
        default="gh",
        type=Path,
        help="path to the gh binary (default is to search in PATH)",
    )
    parser.add_argument(
        '--bazel-bin',
        default="bazelisk",
        type=Path,
        help="path to the bazel/bazelisk binary to be used in the ot-sku repository " +
        "(default is bazelisk, do NOT use OT bazelisk.sh!)",
    )
    parser.add_argument(
        '--ot-sku-repo',
        default=Path(__file__).parents[1],
        type=Path,
        help="path to the ot-sku repository (default is derived from the script path)",
    )
    parser.add_argument(
        '--ot-repo',
        type=Path,
        required=True,
        help="path to the opentitan repository",
    )
    parser.add_argument(
        '--release-notes',
        help="Github release notes (default is automatically generated)",
    )
    parser.add_argument(
        '--release-title',
        help="Github release title (default is the tag)",
    )
    parser.add_argument(
        '--release-repo',
        help="Github release repository (default is the same as ot-sku)",
    )
    parser.add_argument(
        '--release-artifacts',
        help="Comma separated list of artifacts to release (default is all, valid: {artiflist})",
        default=[],
        action='append',
    )
    parser.add_argument(
        '--release-branch',
        required=True,
        help="name of the release branch to create/update",
    )
    parser.add_argument(
        'tag',
        metavar='TAG',
        help="release tag",
    )
    parser.add_argument(
        '--verbose',
        '-v',
        action='count',
        default=0,
        help="increase verbosity level",
    )
    parser.add_argument(
        '--gha-console',
        action='store_true',
        help="add Github action specific console workflow commands for debug/error messages",
    )
    parser.add_argument(
        '--skip-git-clean',
        action='store_true',
        help="skip checks that opentitan/ot-sku repositories are clean (development only)",
    )
    parser.add_argument(
        '--edit-workflow',
        help="Modify anchors in the release.yml file, format is ANCHOR=VALUE",
        default=[],
        action='append',
    )
    step_group = parser.add_mutually_exclusive_group(required=True)
    step_group.add_argument(
        '--pre-sign',
        action='store_true',
        help="Perform pre-signing steps"
    )
    step_group.add_argument(
        '--post-sign',
        action='store_true',
        help="Perform post-signing steps"
    )
    args = parser.parse_args()

    # Parse artifacts list. An empty list means all.
    if not args.release_artifacts:
        args.release_artifacts = list(ARTIFACTS.keys())
    args.release_artifacts = list(set(art for x in args.release_artifacts for art in x.split(',')))
    if invalid := [art for art in args.release_artifacts if art not in ARTIFACTS.keys()]:
        print_error(args, "invalid artifact: {}".format(invalid[0]))
        sys.exit(1)

    # Parse workflow edits.
    workflow_edits = {}
    for edit in args.edit_workflow:
        if '=' not in edit:
            print_error(args, "invalid workflow edit '{edit}', format is ANCHOR=VALUE")
            sys.exit(1)
        anchor, val = edit.split('=', maxsplit=1)
        workflow_edits[anchor] = val
    args.edit_workflow = workflow_edits

    # Resolve some paths since we are going to change the current directory.
    # Also do some sanity checks.
    args.ot_sku_repo = args.ot_sku_repo.resolve()
    if not (args.ot_sku_repo / 'MODULE.bazel').exists() or not (args.ot_sku_repo / 'extension.bzl').exists():  # noqa:E501
        print_error(args, f"{args.ot_sku_repo} does not seem to point to the ot-sku repository")
        sys.exit(1)
    args.ot_repo = args.ot_repo.resolve()
    if not (args.ot_repo / 'MODULE.bazel').exists() or not (args.ot_repo / 'bazelisk.sh').exists():
        print_error(args, f"{args.ot_sku_repo} does not seem to point to the opentitan repository")
        sys.exit(1)

    # Options to use when running bazel
    args.bazelisk = args.ot_repo / 'bazelisk.sh'
    args.bazel_opts = [
        f"--override_module=ot_provisioning_exts={args.ot_sku_repo}",
    ]

    # Make sure that git repositories are clean.
    if not args.skip_git_clean:
        check_repo_clean(args, "ot-sku", args.ot_sku_repo)
        check_repo_clean(args, "opentitan", args.ot_repo)

    # Check if a release already exists.
    release_list = run_gh_or_exit(args, "cannot query release list", [
        "release", "list", "-L", "1000"]).decode('utf-8').split()
    # The format of each line of the output is:
    # <tag> ...
    if any(release.split()[0] == args.tag for release in release_list):
        print_error(args, f"release {args.tag} already exists")
        sys.exit(1)

    # Find the name of the current repository if none was provided:
    if not args.release_repo:
        repo_info = run_gh_or_exit(
            args, "cannot query repository information",
            ["repo", "view", "--json", "nameWithOwner"],
        ).decode('utf-8')
        repo_info = parse_json(args, "repository info", repo_info)
        args.release_repo = repo_info["nameWithOwner"]

    if args.pre_sign:
        create_presign_release(args)
        create_presign_branch(args)
    if args.post_sign:
        create_postsign_release(args)
        update_postsign_branch(args)


if __name__ == '__main__':
    sys.exit(main(sys.argv))

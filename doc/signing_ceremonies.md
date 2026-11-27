<!--
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
-->

# Signing Ceremonies

Signing ceremonies are controlled and auditable processes in which secure private keys are used to sign firmware images.
Their primary goal is to ensure the **authenticity** and **integrity** of signed artifacts, to allow for enforcement of Secure Boot.
For the Open Market SKU, we currently sign the provisioning binaries and the ROM_EXT releases (see [artifacts](./key_management.md#artifacts)).

## Overview

Signing ceremonies should occur in a secure, offline (airgapped) environment.
Production keys are typically held in an offline HSM (ideally secured in a vault), and should generally not be made exportable from that HSM.
If keys need to be exported (for backups), they must be appropriately wrapped, and should be exported/imported as part of a separate ceremony.
During a signing ceremony, raw private key material must *never* be exposed outside of the HSM.

### Responsibilities

Signing ceremonies should have multiple participants with distinct responsibilities -- there should be no one individual able to unilaterally authorize & execute a signing operation.

At *bare minimum* there must be at least **two people** -- an **Operator**, who runs the commands to perform the signing operations, and at least one **Witness**, who independently verifies various aspects of the ceremony.
Ideally there should be at least **three people** -- a **Release Authority**, who approves the release, an **Operator**, and at least one independent **Witness**.
In this model we have separation of duties between the person approving the firmware for signing, and the person controlling access to the key that signs it.
With only two people, the **Witness** would take on the role of the **Release Authority** (and the **Evidence Recorder**, see below).

Participants in the ceremony collectively have the following responsibilities:
* **Release Authority**: the person who approves the release, the version, the target devices, the pre-signing release tag/commit, the hashes of the pre-signing artifacts and the final signatures & signed binaries.
  They are **not allowed** to execute the signing operation via the HSM.
* **HSM Operator**: the person controlling access (ideally both physically & logically) to the HSM and any required authentication factors.
  They are **not allowed** to approve the firmware release.
  They are also **not allowed** to be the sole evidence recorder.
* **Witness**: the person(s) acting as an independent verifier.
  They independently check the artifact digest, release authorization, the identity of the HSM (e.g. serial number), the key identity, the resulting signatures, and the records of the ceremony.
  Despite the name, this person should actively perform independent checks -- **not just observe**!
* **Evidence Recorder**: the person who maintains the signing ceremony log and final sign-off.

In practice, at least one person who is not the HSM Operator must be an evidence recorder -- the main priority is to separate the operator from the witness, and *ideally* the release authority from both.
More sensitive/critical signing ceremonies could consider implementing dual control or quorum-based authorization where supported by the HSM.
Practices such as threshold authorization and separation of trust roles can help reduce the potential for compromise.

It may also be worth considering having multiple evidence recorders in a ceremony -- this will allow you to check for consistent reporting. Any missing information can then be appropriately filled in as corroborated by those present, and any discrepancies in the evidence logs should also be clearly logged.

### Ceremony Logs

Detailed logs should be recorded for every ceremony, such that an independent individual can audit those logs without relying on the memory of the participants.
These logs are committed to the repository, and provide public transparency in the code signing process.
They should be stored under the [`logs/`](../logs) directory as `logs/YYYY-MM-DD.md` based on the date during which the ceremony starts in `UTC`, and should follow a standardized format.
See [`Appendix A`](#appendix-a-example-signing-ceremony-log) for an *example* of a complete signing ceremony log.

Before the ceremony begins, you should ensure that all participants consent to be recorded in the log.
Also, be careful **not** to log sensitive data, which may include -- but is not limited to -- the following:
* HSM PINs & other HSM credentials.
  Ideally you use a pre-registered `hsmtool` profile, but otherwise consider using e.g. `read -rs HSMTOOL_PIN` without echoing.
* Any internal network information for the airgapped HSM environment (IPs, hostnames, etc.)
* Any additional authentication factors.
* The entirety or any portion of the private key material.

Logs should be stored in the same way even for a ceremony that is aborted.
Aborted ceremony logs should include an extra `-aborted` suffix, i.e. `logs/YYYY-MM-DD-aborted.md`.
If multiple ceremonies are carried out on the same day, a unique numerical suffix should be attached, e.g. `logs/YYYY-MM-DD-2-aborted.md` and `logs/YYYY-MM-DD-3.md`.
The first ceremony of a day with multiple ceremonies should *not* have a `-1` suffix attached.
<!-- TODO: consider if there is a nice way to avoid this. Release tags are not great because they will often just duplicate the date... -->

In addition to the log file, the index in [`logs/README.md`](../logs/README.md) should be updated to include information about the HSM session.
<!-- TODO: what will this look like? -->
<!-- TODO: keygen will also need a ceremony log, which might look a bit different. Figure out how this should be handled, and document clearly. -->

### Error Conditions

Before the ceremony starts, you should be clear about the possible error conditions.
A relatively comprehensive (but non-exhaustive) list includes:
* Missing approval,
* Mismatched versions,
* Mismatched target devices / SKUs,
* Mismatched serial number,
* A broken tamper seal,
* An unexplained hash mismatch,
* An unexpected HSM state,
* Unexpected HSM authentication prompts / failures appear,
* The wrong key / HSM slot gets selected,
* The expected signatures are not produced by `hsmtool`,
* Any participant becomes unavailable,
* Any unexpected change to the release branch's `HEAD`,
* Any other deviation from the documented procedure.

Depending on the severity of the events, you may need to either **halt and assess**, or **abort** the ceremony.
Situations like a mistyped command do not warrant ending the ceremony, so long as they do not actually perform an unintended HSM operation, but should still be logged and recorded.
The Release Authority is responsible for making this (and similar) decisions.
Otherwise, if the ceremony is aborted, a log should still be produced, and the error condition that resulted in the withdrawal of the ceremony should be clearly stated.
This log should be committed *without* the rest of the changes from the release branch, in a PR to the default branch, as a standalone commit.

Any orphaned pre-sign GitHub release should be marked as "do not use", and this should be noted in the log.

See [`Appendix B`](#appendix-b-example-signing-ceremony-log-for-an-aborted-ceremony) for an example of a complete signing ceremony log for an aborted ceremony.

#### Post-Ceremony Failure

If the local `signature_test` verification fails, then the release should be aborted.
If the GitHub Release to perform the post-sign release (attaching the signatures) fails, then it should be further investigated.
If the workflow failed due to infrastructure issues (e.g. a GitHub runner being flaky), the Release Authority can decide whether the release should be aborted or whether the action is logged & retried.
If it failed due to an error verifying the signatures, the release should be considered aborted.

If the release is retried, then you must either make sure that any left-over partial GitHub release/tag is first deleted, or a new tag must be used for the post-sign release.
For either outcome, this should be logged.

If the release is instead aborted at this stage, the release branch should be abandoned, and should not be used for a release.
In this case, a fresh commit should be added to the default branch that adds the ceremony log with an `-aborted` suffix, and a note appended about the failure.

<!-- TODO: amend a log note with the post sign release? And noting any flaky reruns there? It would need to include the final tests and release PR as well? -->

## Procedure

### Prolog

Before attempting to begin the signing ceremony, it is worth first performing any necessary tests - regression testing, vulnerability checks, etc.
Then, follow step 1 in the [Release Documentation](./create_release.md) up until you have made the pre-signing release for your desired targets.
The below documentation primarily covers step 2 of that document, formalized for a real signing ceremony.

#### Setup

Before the ceremony begins, steps should be carried out to verify & record the integrity of the environment, and the artifacts to be signed.
A record should be taken of:
 1. The `ot-sku` repository and branch that the pre-signing release was created from.
 2. The full `ot-sku` commit that the pre-signing release was performed from, and the reference of the pre-sign release.
 3. The `ot-sku` release branch being used for the signing.
 4. The `opentitan` repository and branch being used.
 5. The full OpenTitan commit that the releases are built against.
 6. The participants involved in the ceremony, and their roles.
 7. The purpose of the ceremony.

The pre-signing artifacts should be downloaded as a tarball from the automated [GitHub release flow](./create_release.md) -- use the hash of the GitHub release pinned by `_ARCHIVES` in [`extension.bzl`](../extension.bzl) of the release branch to check the integrity of this download.
The build of these artifacts should also be reproduced locally, and you should check their hashes against the downloaded artifacts as well.
`hsmtool` will also need to be used for the signing flow, so this should be built locally, and its hash should also be recorded.
To avoid the ability for a malicious `hsmtool` to be introduced, the witness(es) should watch the build of `hsmtool` at this step and take note of its hash.

```sh
# The `ot-sku` checkout should be at the release branch.
# From your OpenTitan checkout (replace the below path to `ot-sku`).
export BAZEL_OVERRIDE_ARGS=--override_module=ot_provisioning_exts=/path/to/ot-sku

# From the OpenTitan checkout (at `OT_REF`, as recorded in `release.yml`)
bazelisk build --stamp ${BAZEL_OVERRIDE_ARGS} \
    @provisioning_exts//open/perso:presign_perso \
    @provisioning_exts//open/rom_ext:presign_rom_ext \
    //sw/host/hsmtool

# Hashes should only match when built from `OT_REF`, since --stamp embeds the OT commit
sha256sum $(bazelisk cquery --output=files ${BAZEL_OVERRIDE_ARGS} \
    @provisioning_exts//open/perso:presign_perso \
    @provisioning_exts//open/rom_ext:presign_rom_ext \
    //sw/host/hsmtool )
```

You should also check & record the current state of the release branch:

```sh
# From the `ot-sku` checkout
git fetch <remote>
git switch --detach <remote>/<release branch>
# Record the full SHA of the current HEAD
git rev-parse HEAD
# Check that the local checkout is free of any changes
git status
# Check that the only changes from the target are the bot's automatic commits for the release.
# Make sure the changes in these commits match what you would expect.
git diff --stat <presign-commit>..HEAD
```

At this stage, it is also worth verifying the provenance of the artifacts.
You should check that the pre-signing release was correctly scheduled & created from the authorized GitHub flow.
The Release Authority should approve the signing of the actual digest.
Each Release Authority approval during the ceremony should be recorded in the log alongside a relevant timestamp.

Once these artifacts have been built and verified, they should be transferred to portable media, ready to take to the offline signing environment.
For additional security, consider storing this media in a tamper-proof bag marked by a (recorded) serial number.
You should also record how this data was copied across in the ceremony log, and the time at which this occurred (along with relevant timezone information).

During the ceremony, each witness will also need their own independent copy of the pre-signing artifacts and `hsmtool` for verification.
Ideally, each witness should have their own, clean & verified storage medium via which they can acquire these.
One other method could be to have each witness bring a blank storage medium, and transfer the artifacts to both witness devices under observation, on a controlled workstation (*not* one with access to the HSM).
In practice, it may be that these copies are sourced otherwise: the key is to demonstrate independent buildability, and record evidence.
For verification purposes, witnesses should also obtain a copy of OpenTitanTool (by building `//sw/host/opentitantool` from the matching OpenTitan commit).
This can simply be available on their own devices for verification.
<!-- TODO: how strict should we be about this? -->

#### In the Offline Environment

When all ceremony participants have entered the offline environment and it has been appropriately sealed, a record of the time at which the ceremony began should be recorded.
This should again be captured along with relevant timezone information; if the environment does not have access to accurate timekeeping, then a time should be taken before entering the offline environment, and a note should be made of how time was kept during the ceremony.
To avoid errors, it is also worth re-stating the participants in the ceremony at this stage.
All participants should confirm the integrity and confidentiality of the environment.

The HSM operator(s) should remove any additional protections around the secure media and the HSM.
At this point, integrity of the HSM should be checked, also making a record of any non-sensitive information.
For example, the HSM serial number, security state and access policy should all be checked.

Ideally, additional checks will be closely enforced in this environment, e.g.
* Verification of operating system images, and any additional HSM-specific signing utilities & tools.
* Check that unused network interfaces are disabled, and wireless / Bluetooth etc. peripherals are not present.
  Witnesses can each have their own approved offline devices for independent checks.
* Use tamper-evident seals & physical access records where necessary.

The HSM Operator(s) and witness(es) should use `script` or a similar utility to automatically capture full terminal output.
Though sensitive data should not echo (e.g. PIN entries, unless passed directly via arguments), this should still be checked with caution.
Where available, records with timing data should be included, e.g. `script --timing=time.tm signing.log`.

Once the signing environment has been verified, the HSM operator(s) should carry out any necessary steps to allow use of the HSM (making the equipment ready).
Any non-sensitive steps (e.g. packages used to communicate with the HSM) should be recorded.
For example, the `hsmtool` profile, module path and any (non-sensitive) vendor environment variables should be documented.
Do not directly dump the `env`, as this may contain confidential information.

The HSM operator(s) should then mount the portable media to a new staging directory, and then copy across the release tarball and `hsmtool` binary.
For example:

```sh
export STAGING_DIR=... # Depends on your HSM's environment
mount -o ro /dev/cdrom /mnt
mkdir -p ${STAGING_DIR}
cd ${STAGING_DIR}
cp /mnt/presign_perso.tar.xz .
cp /mnt/presign_rom_ext.tar.xz .
cp /mnt/hsmtool .
umount /mnt
chmod +x ./hsmtool
```

Before the ceremony begins, the HSM Operator(s) and each witness should check the digest of these artifacts, e.g.

```sh
sha256sum presign_perso.tar.xz presign_rom_ext.tar.xz hsmtool
```

Witnesses should directly read the hashes from the HSM Operator(s) screen, and should check that they match their own independent copies.
For `hsmtool`, the witnesses should check that the hash matches the binary that was built during setup.
The Release Authority should again approve these specific hashes.
At this stage, it is also worth restating the artifacts being signed, the version, the purpose of the ceremony and the target SKU.

At this stage, you should record the full output of `./hsmtool token list` clearly in the log.
When the Release Authority has approved the hashes, the signing can begin.

### Signing

For avoidance of doubt: unless explicitly authorized by policy to do so, the private key material should not be exported from the HSM.
Signing should occur within the HSM via the required signing tooling.
No signing operations outside of those specified in the tarballs should be carried out.
No excess operations (key generation, import, export, etc.) should be carried out.
In the case that any signing operations fail or an unintended HSM operation is mistakenly conducted, this should be recorded and the ceremony aborted.

Each signing archive contains a `provisioning_{SKU}.json` or a `rom_ext.json` command script to be input to `hsmtool`.
The following instructions assume that `SKU` is `ot00`, i.e. the provisioning archive command script is called `provisioning_ot00.json`.

```sh
mkdir presign_perso presign_rom_ext
tar -xvf presign_perso.tar.xz   -C presign_perso
tar -xvf presign_rom_ext.tar.xz -C presign_rom_ext
```

Each witness should check both of these command scripts and ensure that these signing operations that are listed are what is expected.
Specifically:
 * Only `ecdsa-sign` and/or `slh-dsa-sign` commands appear.
 * A ceremony in which only ECDSA P-256 signing is expected should not include any SLH-DSA signing commands.
 * Check that, for each command, the `label` matches the intended (& approved) key.
 * Check that the `domain` (signature mode) of SLH-DSA signing operations is as expected.
 * Check that each expected digest is signed exactly once per expected algorithm.

The witness(es) should also confirm the contents of the pre-signing images via their manifests:

```sh
# Run from each witness' own workspace. They should each locally extract the
# tarballs to `presign_perso` and `presign_rom_ext` and verify the artifacts.
# They should have `opentitantool` available to them on their own devices.

# For each *.pre-signing image in each tarball, confirm the:
#  - kind
#  - identifier
#  - pub key (should match the `otp_encoded` values using
#    `opentitantool ecdsa key show skus/open/keys/root/<key>.pub.der`)
#  - usage constraints
#  - security version
#  - max key version
for f in presign_*/*.pre-signing; do
  echo "$f"; ./opentitantool image manifest show "$f";
done
# For each image, check that the digest matches the image.
for img in presign_*/*.pre-signing; do
  artifact="${img%.pre-signing}.digest"
  ./opentitantool image digest --bin /tmp/d.bin "$img" >/dev/null \
    && cmp -s /tmp/d.bin "$artifact" && echo "OK $img" || echo "FAIL $img"
done
# Check that there is a 1:1 image <-> digest pairing.
diff <(basename -s .pre-signing presign_*/*.pre-signing) <(basename -s .digest presign_*/*.digest)
```

Then, once the Release Authority has given approval once more (approving each individual image to be signed, including e.g. FPGA variants), the HSM Operator(s) should carry out the signing operations:

```sh
# Record how `HSMTOOL_CUSTOM_ARGS` is defined here, e.g. as `--profile earlgrey_ot00`.
# However, this should censor any private information (e.g. pins).
pushd presign_perso
../hsmtool $HSMTOOL_CUSTOM_ARGS exec provisioning_ot00.json
popd
pushd presign_rom_ext
../hsmtool $HSMTOOL_CUSTOM_ARGS exec rom_ext.json
popd
```

The outputs should take the form of `*.ecdsa_sig` or `*.slh_dsa_sig` files, matching the type of signing that was performed.
The HSM Operator(s) should confirm that these signature files were generated as expected, and should perform a sanity check that the generated signatures are of the correct size (e.g. 64 bytes for ECDSA P-256, and 7856 bytes for SLH-DSA with a `*-128s` parameter set).
The signature files should then be copied to portable media -- ideally, a separate, clean outbound portable media device should be used.
You should record the commands that you use to do this, e.g.

```sh
# Record the hash of each individual signature for traceability.
sha256sum presign_perso/*_sig presign_rom_ext/*_sig

# Tar the signatures, and note the hash of the tarball to ensure integrity
tar cvf perso_signatures.tar   --transform 's,.*/,,g' presign_perso/*_sig
tar cvf rom_ext_signatures.tar --transform 's,.*/,,g' presign_rom_ext/*_sig
sha256sum perso_signatures.tar rom_ext_signatures.tar

# Identify the outbound media and record its model & serial number in the log
lsblk -o NAME,SIZE,MODEL,SERIAL
export OUT_DEV=/dev/sdx1  # Depends on your workstation's environment
mkdir -p /mnt/signatures
mount ${OUT_DEV} /mnt/signatures

# The witness(es) should confirm that the outbound media is empty before anything is copied
ls -al /mnt/signatures
cp perso_signatures.tar rom_ext_signatures.tar /mnt/signatures
exit  # End the `script` session so the transcript is complete.
cp signing.log time.tm /mnt/signatures
sha256sum /mnt/signatures/*
sync

# The witness(es) should confirm that the outbound media contains only the signatures
# and the session transcript.
ls -al /mnt/signatures
umount /mnt/signatures
```

#### Teardown

Information about the teardown procedure should be recorded, including the time at which the ceremony concluded.
Explicitly state (if true) that the signing operation completed and the expected signatures were generated.
You should also explicitly confirm that private keys remained within the HSM.
As applicable, consider also recording HSM session closure & shutdown, as well as removal of backups, tokens, authentication devices, etc.
Any steps taken to secure equipment (e.g. in tamper-proof bags with an identifiable serial number) should also be recorded.

It is also prudent to record the final state of the secure environment as the ceremony ends: workstation identifiers, their power state, confirmation of removal of additional media, and any deviations from the approved configuration.
The final state/custody of the HSM, source media and evidence records should be described.
Each witness should only attest to actions they directly observed, and evidence they independently checked.

Finally, the Release Authority should approve the end of the ceremony after they are happy that all items in this document have been appropriately followed and concluded.

### Epilog

#### Testing

After the ceremony (and back in an online environment), participants should carry out post-ceremony testing.
Anybody can perform this testing, but ideally it would not be carried out by the HSM operator.
The person performing the testing and the present witnesses should all be listed.

The tester should checkout the release branch and copy across the signatures.

```sh
# Run from the `ot-sku` repository
git fetch <remote>
git switch --detach <remote>/<release branch>

# Remove any existing (stale) signature files.
rm -f skus/open/signatures/perso/*_sig skus/open/signatures/rom_ext/*_sig

# Mount the outbound media from the ceremony.
# Check that its model & serial number match those recorded in the log.
lsblk -o NAME,SIZE,MODEL,SERIAL
export OUT_DEV=/dev/sdx1  # Depends on your workstation's environment.
mkdir -p /mnt/signatures
mount -o ro ${OUT_DEV} /mnt/signatures

# Check that the tarball hashes match those recorded during the ceremony.
sha256sum /mnt/signatures/perso_signatures.tar /mnt/signatures/rom_ext_signatures.tar

# Extract the signatures.
tar -xvf /mnt/signatures/perso_signatures.tar   -C skus/open/signatures/perso/
tar -xvf /mnt/signatures/rom_ext_signatures.tar -C skus/open/signatures/rom_ext/
umount /mnt/signatures

# The witness(es) should compare each signature's SHA to the values
# previously recorded in the ceremony log.
ls -al skus/open/signatures/perso/ skus/open/signatures/rom_ext/
sha256sum skus/open/signatures/perso/*_sig skus/open/signatures/rom_ext/*_sig
```

All of these steps should be added to the signing ceremony log.
Next, tests should be performed locally to ensure that the signatures that were produced look correct (these are also checked in the post-sign release CI, but we double check here).

```sh
# Run from the `opentitan` repository
bazelisk test ${BAZEL_OVERRIDE_ARGS} --cache_test_results=no --test_output=streamed \
    @provisioning_exts//open/perso:signature_test \
    @provisioning_exts//open/rom_ext:signature_test
```

The output of these tests should be recorded in the ceremony log.

#### Committing the Signatures

As documented in the [Release Documentation](./create_release.md), you can use the following steps to commit the signatures:

```sh
# Run from the root of the `ot-sku` repository. First, stage the signature files.
# You must use `--force` since these are git-ignored on purpose.
git add --force skus/open/signatures/perso/*_sig skus/open/signatures/rom_ext/*_sig
# The witness(es) should verify the output of:
git diff --cached --stat
# Add the signing ceremony log, covering all steps taken so far.
git add logs/YYYY-MM-DD.md
# Commit the signing artifacts. Optionally add other participants' sign-offs here.
git commit -vs
```

Before pushing, you should ideally make sure that your `git status` is clean and check that the `signature_test` targets above still work.
You should also do one final check that the release branch's `HEAD` remains unchanged before you push the commit.

```sh
# Check the current HEAD, and compare with the SHA recorded during the setup phase
git fetch
git rev-parse <remote>/<release branch>
# Create a PR to the release branch with the new commit
```

#### Finalizing the release

From this point onwards, you can follow step 3 of the [Release Documentation](./create_release.md) to create the post-signing release.
Assuming that this works, you can then checkout the final release branch and verify that the signed binaries are working as intended.

The following documentation duplicates & modifies the 'Verification' step in the [Key Management Documentation](./key_management.md):

```sh
# From the `ot-sku` repository, pull the release branch to get the post-sign artifacts
git checkout <release branch>
git pull

# Run tests from the `opentitan` repository, at the `OT_REF` checkout.
# First build the OTP constants & owner configuration:
bazelisk build ${BAZEL_OVERRIDE_ARGS} @provisioning_exts//open/otp/ot00:otp_consts
bazelisk build ${BAZEL_OVERRIDE_ARGS} @provisioning_exts//open/rom_ext:owner_config_bin

# Test the signatures on the signed binaries:
bazelisk test ${BAZEL_OVERRIDE_ARGS} --test_output=streamed \
  @provisioning_exts//open/binaries/perso:signature_test \
  @provisioning_exts//open/binaries/rom_ext:signature_test

# Test the multi-stage end-to-end orchestrator test on FPGA. This will run the full
# provisioning flow, in multiple stages (CP only, then FT only), and boot into
# the ROM_EXT. With a CW310 available:
bazelisk test ${BAZEL_OVERRIDE_ARGS} --test_output=streamed \
  //sw/host/provisioning/orchestrator/tests:e2e_multistage_ot00_staging_hyper310_test

# Or with a CW340 available:
bazelisk test ${BAZEL_OVERRIDE_ARGS} --test_output=streamed \
  //sw/host/provisioning/orchestrator/tests:e2e_multistage_ot00_staging_cw340_test
```

Regardless of the outcome of the post-signing release and final testing, a new commit should be added updating the signing log accordingly.
This should state the outcome of the release, make a note of the release tag and post-release branch, and the status of the ceremony.
No content that was introduced in the commit containing the initial log & signatures should be removed or modified.
The ceremony index should also be populated accordingly with a note of the ceremony.

```sh
git add logs/YYYY-MM-DD.md logs/README.md
git commit -vs # ...
git push <remote> <rbranch>  #... and make a PR.
```

### Finishing

If the release was a success, a PR should be made from the release branch to the default branch.
This PR should pass all CI before it is merged, showing that the tests are all passing.
<!-- TODO: the release PR will contain the `release.yml` anchor edits, these need to be undone in the final release. This should perhaps be addressed in the release flow itself. Unhandled for now. -->

As documented in the ['Error Conditions'](#error-conditions) section, if the release was a failure, a single commit containing only the changes under the `logs/` sub-directory should be included in a PR to the default branch.
The ceremony log name should have the `-aborted` suffix added, and the reason for the failure of the ceremony should clearly be stated.

Regardless of the success or failure of the ceremony, all participants should approve the PR that adds the log.
They ideally should also each have `Signed-off-by:` trailers on the relevant commits.

## Appendix A: Example Signing Ceremony Log

<!-- TODO: also add a template which can be filled in as appropriate -->

All names, hashes and serial numbers below are fictional.

````markdown
# Signing Ceremony 2026-10-19

- Purpose: Release new ROM_EXT and FT personalization binaries for the Open Market ot00 silicon SKU.
- Participants:
  - John Doe [Release Authority, GitHub: JohnDoe5192],
  - Abigail Reeves [HSM Operator, GitHub: reevesaby_],
  - Xin Yu [Witness & Evidence Recorder, GitHub: xinyu-gh],
  - Michael Smith [Witness & Evidence Recorder, GitHub: ms-ot14],
- All times are in UTC.

## Sources

- Built from lowRISC/ot-sku:main @ commit 80eec0db2e8f02c20cd0b3cc391fa2d3b8bbe2c2.
- Built from lowRISC/opentitan:earlgrey_1.0.0 @ commit f675f8b3ee447923569f271a4bbd5ac6129065a9.
- Pre-Sign Release Tag: `PreRelease2026_10_19`
- Release branch: `release_2026_10_19` @ commit eddc5756e7c019ac6b733e7d51c689232c58c990.
  `git log --oneline 80eec0db..HEAD` shows only the automated commits:
  - `eddc5756` Prepare release flow for post-signing (`.github/workflows/release.yml` anchors only)
  - `8f5855c3` Update archives for presigning release PreRelease2026_10_19 (`extension.bzl` `_ARCHIVES` only)

## Setup

- 09:23: Setup started by Xin Yu and Michael Smith, each on their own workstation.
- 09:25: Release Authority confirmed the pre-sign release was created by the `Create a release` workflow
  (run https://github.com/lowRISC/ot-sku/actions/runs/1234567890).
- 09:27: Both witnesses checked the state of the release branch:
  ```sh
  git fetch origin
  git switch --detach origin/release_2026_10_19
  git rev-parse HEAD                      # eddc5756e7c019ac6b733e7d51c689232c58c990
  git status                              # clean
  git diff --stat 80eec0db..HEAD          # only extension.bzl and .github/workflows/release.yml
  ```
- 09:31-09:37: Witnesses each downloaded the pre-sign assets, and independently rebuilt them and `hsmtool` at the sources above:
  ```sh
  curl -fLO https://github.com/lowRISC/ot-sku/releases/download/PreRelease2026_10_19/presign_perso.tar.xz
  curl -fLO https://github.com/lowRISC/ot-sku/releases/download/PreRelease2026_10_19/presign_rom_ext.tar.xz
  sha256sum presign_perso.tar.xz presign_rom_ext.tar.xz

  # From a clean OpenTitan checkout at f675f8b3ee447923569f271a4bbd5ac6129065a9
  export BAZEL_OVERRIDE_ARGS=--override_module=ot_provisioning_exts=$HOME/ot-sku
  ./bazelisk.sh build --stamp ${BAZEL_OVERRIDE_ARGS} \
      @provisioning_exts//open/perso:presign_perso \
      @provisioning_exts//open/rom_ext:presign_rom_ext \
      //sw/host/hsmtool
  sha256sum $(./bazelisk.sh cquery --output=files ${BAZEL_OVERRIDE_ARGS} \
      @provisioning_exts//open/perso:presign_perso \
      @provisioning_exts//open/rom_ext:presign_rom_ext \
      //sw/host/hsmtool)
  ```
  For each artifact, the GitHub asset, the `_ARCHIVES` hash and both local rebuilds all matched:
  - `presign_perso.tar.xz`: `35010d0f172a1b9824b183c15a340d88e2f488378e963eb18884ddd781242a75`
  - `presign_rom_ext.tar.xz`: `722f7dbf08288478490642cccf862115936a926b66dafdf6fa167a2053bee514`

  For `hsmtool`, both witnesses' builds matched with `90d3402b16996b2c67bd5410700c960d29a15e2b8115633ff577b236006f2715`.
- 09:40: **Approval** (Release Authority): pre-sign release `PreRelease2026_10_19` will be signed and uses the hashes above.
- 09:46: Michael Smith copied the two tarballs and `hsmtool` to inbound media (USB, model Kingston IronKey Locker+ 50 with serial `4C530001230920115432`) on their workstation, observed by Xin Yu:
  ```sh
  cp presign_perso.tar.xz presign_rom_ext.tar.xz hsmtool /media/msmith/IRONKEY/
  sha256sum /media/msmith/IRONKEY/*       # matched the hashes above
  sync && umount /media/msmith/IRONKEY
  ```
  The media was sealed in tamper-evident bag `TB-004512`.

## Prolog

- 10:05: All four participants entered the signing room.
  The room was sealed and the ceremony began.
  Time was kept using the wall clock, which was checked against an online clock at 10:02 (+0s).
- 10:07: Participants and roles were re-stated as listed above.
  All participants confirmed the room's integrity & confidentiality.
- 10:09: Abigail Reeves removed the HSM and signing workstation from their storage.
  Seals were checked by both witnesses:
  - HSM tamper bag `TB-004498`: intact, serial matches the previous `2026-07-02` log.
  - Inbound media tamper bag `TB-004512`: intact, serial matches setup.
  - Signing workstation `SIGN-WS-01`: seal intact.
- 10:14: HSM: serial `HSM-7731-0042`, firmware 7.8.4, FIPS mode enabled, no tamper events in the HSM audit log.
- 10:16: Abigail Reeves started the terminal transcript and made the HSM ready.
  The `opensc` package was used to communicate with the token holding the key material.
  The `ot00` profile in `~/.config/hsmtool/profiles.json` supplies the token, user and PIN.
  ```sh
  script --timing=time.tm signing.log
  export HSMTOOL_MODULE=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
  export HSMTOOL_CUSTOM_ARGS="--profile ot00"
  ```
- 10:21: Inbound media was mounted read-only and the artifacts were copied to the staging directory:
  ```sh
  export STAGING_DIR=/srv/signing/2026-10-19
  mount -o ro /dev/sdb1 /mnt
  mkdir -p ${STAGING_DIR} && cd ${STAGING_DIR}
  cp /mnt/presign_perso.tar.xz /mnt/presign_rom_ext.tar.xz /mnt/hsmtool .
  umount /mnt
  chmod +x ./hsmtool
  sha256sum presign_perso.tar.xz presign_rom_ext.tar.xz hsmtool
  ```
- 10:23: Both witnesses read the hashes from the operator's screen, and both confirmed they matched their own copies and the setup hashes.
- 10:25: **Approval** (Release Authority): staged artifact hashes.
- 10:26: Abigail Reeves mistyped `./hsmtool tokn list` -- it failed to parse and performed no HSM operation.
  The Release Authority decided to continue.
- 10:27: `./hsmtool token list` output:
  ```json
  {
    "tokens": [
      {
        "label": "ot00-root",
        "manufacturer_id": "Vendor",
        "model": "HSM-7731",
        "serial_number": "HSM-7731-0042"
      }
    ]
  }
  ```

## Witness Checks

Both witnesses independently performed the following checks on their own devices, after extracting the tarballs to `presign_perso` and `presign_rom_ext`.

- 10:31: Both witnesses manually inspected the command scripts.
  `provisioning_ot00.json` (16 commands) and `rom_ext.json` (6 commands) contain only `ecdsa-sign` and `slh-dsa-sign` commands.
  - ECDSA label is always `ot00-earlgrey-a2-root-ecdsa-prod-0`.
  - SLH-DSA label is always `ot00-earlgrey-a2-root-slhdsa-prod-0`, with domain `PreHashedSha256`.
  - Each of the 11 digests is signed exactly once per algorithm.
- 10:38: Manifest check:
  ```sh
  opentitantool ecdsa key show skus/open/keys/root/ot00-earlgrey-a2-root-ecdsa-prod-0.pub.der
  for f in presign_*/*.pre-signing; do echo "$f"; ./opentitantool image manifest show "$f"; done
  ```
  - kind is `RomExt` and identifier is `0x4552544f` for all images.
  - `pub_key` matches the `otp_encoded` value of `ot00-earlgrey-a2-root-ecdsa-prod-0`.
  - Usage constraints, `security_version` and `max_key_version` are as expected.
- 10:44: Digest and pairing checks:
  ```sh
  for img in presign_*/*.pre-signing; do
    artifact="${img%.pre-signing}.digest"
    ./opentitantool image digest --bin /tmp/d.bin "$img" >/dev/null \
      && cmp -s /tmp/d.bin "$artifact" && echo "OK $img" || echo "FAIL $img"
  done
  diff <(basename -s .pre-signing presign_*/*.pre-signing) <(basename -s .digest presign_*/*.digest)
  ```
  `OK` for all 11 images, and no differences in the pairing check.
- 10:46: **Approval** (Release Authority): signing of all 11 images, including the FPGA and QEMU variants.

## Signing

- 10:48: Archives extracted on the signing workstation:
  ```sh
  mkdir presign_perso presign_rom_ext
  tar -xvf presign_perso.tar.xz -C presign_perso
  tar -xvf presign_rom_ext.tar.xz -C presign_rom_ext
  ```
- 10:49: Signing was performed with:
  ```sh
  pushd presign_perso
  ../hsmtool $HSMTOOL_CUSTOM_ARGS exec provisioning_ot00.json
  popd
  pushd presign_rom_ext
  ../hsmtool $HSMTOOL_CUSTOM_ARGS exec rom_ext.json
  popd
  ```
- 10:55: Checked the outputs with `ls -al presign_perso presign_rom_ext`.
  Signing produced 11 `*.ecdsa_sig` files and 11 `*.slh_dsa_sig` files, all of which were the expected size.
- 10:57: Signature hashes (`sha256sum presign_perso/*_sig presign_rom_ext/*_sig`):
  ```
  cf155263103141a51a600fd21a9bb11a46d323d150f306c52c9e8f66dc250f3a  presign_perso/ft_flash_scramble_ot00_fpga_cw340_rom_with_fake_keys.ecdsa_sig
  950035a443fba88b77a047fe90931c318494293692314f9596273fc1e2290df1  presign_perso/ft_flash_scramble_ot00_fpga_cw340_rom_with_fake_keys.slh_dsa_sig
  6203728362b3baf6ed2ff09ef8d30083db14e5c65a4d4ccb8a8e5100ae1db1fe  presign_perso/ft_flash_scramble_ot00_fpga_hyper310_rom_with_fake_keys.ecdsa_sig
  d11eb34d59ca24f9e64dc0876b900f0aaffbffc810bdefbb157ddb42a44a708b  presign_perso/ft_flash_scramble_ot00_fpga_hyper310_rom_with_fake_keys.slh_dsa_sig
  5e8db9a98ca211f350bed6ac0aee02aca543d54bf517cf514902616776af7fb1  presign_perso/ft_flash_scramble_ot00_silicon_creator.ecdsa_sig
  5d8f672dfe546013a7b84e21080b7ed79cce57b884b35dc2a9fb1073106b091a  presign_perso/ft_flash_scramble_ot00_silicon_creator.slh_dsa_sig
  04c7954386cc67a247699ba3fb2376ef9f2cd512e92488b56ef37f6ad1d73d9c  presign_perso/ft_flash_scramble_ot00_sim_qemu_rom_with_fake_keys.ecdsa_sig
  501c836fc3cd9f19a52ba39274ea68d25e0225f01c4fba8194d40ea1bfe5c3fb  presign_perso/ft_flash_scramble_ot00_sim_qemu_rom_with_fake_keys.slh_dsa_sig
  2e9362a0a1f06044855a02a0cd163304c4cf74afa9bc9f6efd73a53ef4e712a4  presign_perso/ft_personalize_ot00_fpga_cw340_rom_with_fake_keys.ecdsa_sig
  a6541aaf76f44d70bc53edbd9831d7e05445485804a1d694be6339fbb8ee49df  presign_perso/ft_personalize_ot00_fpga_cw340_rom_with_fake_keys.slh_dsa_sig
  1195fc288c1bd2b3906d72456f37c296f74c550b606bf96c9ced9eedad0daadd  presign_perso/ft_personalize_ot00_fpga_hyper310_rom_with_fake_keys.ecdsa_sig
  fc7309f5904cadd582b610b83dbe778e99221e9dc0627fec54100a1c42b8d545  presign_perso/ft_personalize_ot00_fpga_hyper310_rom_with_fake_keys.slh_dsa_sig
  8c8657d7e214be2599048054b477545f053c06ff13be4afe455b67733a1f6798  presign_perso/ft_personalize_ot00_silicon_creator.ecdsa_sig
  a9439a44bb5f5cc81e3459628a4b7da7914dadfddcb4ec37638f1832e7ee8649  presign_perso/ft_personalize_ot00_silicon_creator.slh_dsa_sig
  0a3efd773409936f041be0dd902e18e7ffdebed79f372dc8f26594a235cd8c01  presign_perso/ft_personalize_ot00_sim_qemu_rom_with_fake_keys.ecdsa_sig
  47b507021ed6e46333405b2d5d555466564222bcce82b4af91c8407173582d0b  presign_perso/ft_personalize_ot00_sim_qemu_rom_with_fake_keys.slh_dsa_sig
  40e0f166be89ce3e9eaeafc7ade092a9385bd1337a1efa01731ea147fa4c0e1f  presign_rom_ext/rom_ext_dice_x509_prod_slot_virtual_fpga_cw310.ecdsa_sig
  6e77d178f4d6b20b0411f9bcf50fb0ad4c05f93b9c000da67ca4789bf6d8c20d  presign_rom_ext/rom_ext_dice_x509_prod_slot_virtual_fpga_cw310.slh_dsa_sig
  f26d8f9807d2f64bf5a365cb45964b4a6daa46d976c6052201476562f487201e  presign_rom_ext/rom_ext_dice_x509_prod_slot_virtual_fpga_cw340.ecdsa_sig
  423a04713291cd7b08dd9cb4f13a72462da7f9e87b0ef03cf5459d3ebaaa71b0  presign_rom_ext/rom_ext_dice_x509_prod_slot_virtual_fpga_cw340.slh_dsa_sig
  a32e9b4e77ea2e16b223ff411edd76587f823c6e02e2a6c4c98dc38fa6f47736  presign_rom_ext/rom_ext_dice_x509_prod_slot_virtual_silicon_creator.ecdsa_sig
  6d2d8a5f448f6f13cd61e9b63bc4219d6cfae71a0c23a1b4274dd017caeb1a4d  presign_rom_ext/rom_ext_dice_x509_prod_slot_virtual_silicon_creator.slh_dsa_sig
  ```
- 11:00: The signatures were then packaged into tarballs:
  ```sh
  tar cvf perso_signatures.tar --transform 's,.*/,,g' presign_perso/*_sig
  tar cvf rom_ext_signatures.tar --transform 's,.*/,,g' presign_rom_ext/*_sig
  sha256sum perso_signatures.tar rom_ext_signatures.tar
  ```
  - `perso_signatures.tar`: `dfef1e4a9b934eed2e3fbcc4d392cc0bc963101025e3bfc853bffb735f3da76f`
  - `rom_ext_signatures.tar`: `7bd00a988dc186478d8c548aba92661f25334ee07b1e0eba172261567a2a218d`
- 11:02: Outbound media: USB, model Kingston DataTraveler Exodia, serial `408D5C1EAE21F4A1`.
  ```sh
  mkdir -p /mnt/signatures
  mount /dev/sdc1 /mnt/signatures
  ls -al /mnt/signatures                  # witnesses confirmed it was empty
  cp perso_signatures.tar rom_ext_signatures.tar /mnt/signatures
  ```
- 11:04: The HSM operator's `script` session ended, and the transcripts were copied to the outbound media:
  ```sh
  exit
  cp signing.log time.tm /mnt/signatures
  sha256sum /mnt/signatures/*
  sync
  ls -al /mnt/signatures
  umount /mnt/signatures
  ```
  - `signing.log`: `431ff9bdaa405ff575a03f6bce82d7ed54fb9b6009cbc8e07433bc92e4db1974`
  - `time.tm`: `ce662a0209818d8fa49ab34631ba1880a30de622519499d6e4918bbed8e7eb08`

  Both witnesses reviewed `signing.log` and confirmed that it contains no sensitive data.
  Both witnesses confirmed the outbound media contains only the two signature tarballs and the two transcript files.

## Teardown

- 11:08: The signing operations were completed, and all private keys remained within the HSM.
- 11:09: HSM session closed and the HSM was powered off.
- 11:11: The staging directory was deleted (`rm -rf ${STAGING_DIR}`) and `SIGN-WS-01` was powered off.
- 11:13: Equipment was re-sealed (with the seal serials checked by both witnesses):
  - HSM: tamper bag `TB-004530`.
  - Inbound media: tamper bag `TB-004531`.
  - `SIGN-WS-01`: seal `CS-00217`.
- 11:14: Outbound media held by Michael Smith for post-ceremony testing.
- 11:15: **Approval** (Release Authority): end of ceremony.
  The signing room was unsealed and the ceremony ended.

## Post-Ceremony Testing

- 11:32: Testing performed by Michael Smith, witnessed by Xin Yu and John Doe.
- 11:33: Release branch checked, and the signatures copied across:
  ```sh
  git fetch origin
  git switch --detach origin/release_2026_10_19
  git rev-parse HEAD                      # eddc5756e7c019ac6b733e7d51c689232c58c990, matching setup
  rm -f skus/open/signatures/perso/*_sig skus/open/signatures/rom_ext/*_sig
  lsblk -o NAME,SIZE,MODEL,SERIAL         # outbound media serial matched
  mkdir -p /mnt/signatures
  mount -o ro /dev/sdb1 /mnt/signatures
  sha256sum /mnt/signatures/*             # matched the hashes above
  tar -xvf /mnt/signatures/perso_signatures.tar   -C skus/open/signatures/perso/
  tar -xvf /mnt/signatures/rom_ext_signatures.tar -C skus/open/signatures/rom_ext/
  umount /mnt/signatures
  sha256sum skus/open/signatures/perso/*_sig skus/open/signatures/rom_ext/*_sig
  ```
  All 22 signature hashes matched those recorded above.
- 11:40: Signature tests were then run from the OpenTitan checkout:
  ```sh
  ./bazelisk.sh test ${BAZEL_OVERRIDE_ARGS} --cache_test_results=no --test_output=streamed \
      @provisioning_exts//open/perso:signature_test \
      @provisioning_exts//open/rom_ext:signature_test
  ```
  ```
  @provisioning_exts//open/perso:signature_test     PASSED in 2.1s
  @provisioning_exts//open/rom_ext:signature_test   PASSED in 1.4s
  ```
- 11:58: Committed the signatures and this log, and opened a PR to `release_2026_10_19` (https://github.com/lowRISC/ot-sku/pull/123456):
  ```sh
  git add --force skus/open/signatures/perso/*_sig skus/open/signatures/rom_ext/*_sig
  git diff --cached --stat                # 22 new signature files only
  git add logs/2026-10-19.md
  git commit -vs                          # 2c2d8a2d905a9872da0577f36ceaf33df3a6857b
  git switch -c signatures_2026_10_19
  git push origin signatures_2026_10_19
  ```

## Post-Sign Release

This section was appended after the post-sign release.

- 2026-10-19 13:10: PR #123456 was merged into `release_2026_10_19` by John Doe.
- 2026-10-19 13:14: The `Create a release` workflow was run from `release_2026_10_19`, with `release_type=post-sign` and `ot_ref=f675f8b3ee447923569f271a4bbd5ac6129065a9`.
  Run: https://github.com/lowRISC/ot-sku/actions/runs/1234598765.
  Result: The run failed, which John Doe and Michael Smith determined to be due to runner infrastructure flakiness.
  John Doe deleted the remnant orphaned tag and the Release Authority approved re-running the workflow.
  Run: https://github.com/lowRISC/ot-sku/actions/runs/1234598766.
  Result: The run successfully finished.
- Post-Sign Release Tag: `Release2026_10_19`
  - `perso_release.tar.xz`: `ecc7458731c16f79358fae1032ab88ac6033d3ae3c55c19b0c4fa48855a4e3dc`
  - `rom_ext_release.tar.xz`: `7f7c1a511a228670de25b27b533cb39b1cfbfce053ae2808ee18697ed634c9be`
- The workflow pushed `8a6a87763e4debd9fcf2ea6293406839f72d3218` (Update archives for release) to `release_2026_10_19`.
- 2026-10-19 14:02: Final testing by Xin Yu, witnessed by Michael Smith:
  - `@provisioning_exts//open/binaries/{perso,rom_ext}:signature_test`: PASSED.
  - `e2e_multistage_ot00_staging_cw340_test` on CW340: PASSED.
- Ceremony status: **complete**.
- Outcome: **Success**.

## Sign-Off

The participants approve that this log is an accurate record of the ceremony:

- John Doe (Release Authority): approved.
- Abigail Reeves (HSM Operator): approved.
- Xin Yu (Witness & Evidence Recorder): approved.
- Michael Smith (Witness & Evidence Recorder): approved.
````

## Appendix B: Example Signing Ceremony Log for an Aborted Ceremony

````markdown
# Signing Ceremony 2026-10-20-2-aborted

- Purpose: Release a new ROM_EXT binary for the Open Market ot00 silicon SKU.
- This is the second ceremony on 2026-10-20.
- Participants:
  - John Doe [Release Authority, GitHub: JohnDoe5192],
  - Abigail Reeves [HSM Operator, GitHub: reevesaby_],
  - Xin Yu [Witness & Evidence Recorder, GitHub: xinyu-gh],
- All times are in UTC.

<!-- The log continues as normal (as in Appendix A) until an error occurs. -->

- 14:46: The witness read the hashes from the operator's screen, and confirmed they matched their own copies and the setup hashes.
- 14:48: **Approval** (Release Authority): staged artifact hashes.
- 14:52: Witness check of `rom_ext.json` failed.
  On manual inspection, all 3 `ecdsa-sign` commands use label `ot00-earlgrey-a2-root-ecdsa-dev-0`, not the approved `ot00-earlgrey-a2-root-ecdsa-prod-0`.
  The `slh-dsa-sign` commands correctly use `ot00-earlgrey-a2-root-slhdsa-prod-0`.
- 14:55: The witness compared the image manifests against the root keys:
  ```sh
  for f in presign_rom_ext/*.pre-signing; do ./opentitantool image manifest show "$f" | grep pub_key; done
  opentitantool ecdsa key show skus/open/keys/root/ot00-earlgrey-a2-root-ecdsa-dev-0.pub.der
  ```
  The `pub_key` of all 3 images matches the `otp_encoded` value of `ecdsa-dev-0`, so the images were built for the wrong key.
  The cause is in the GitHub Release's `ot-sku` sources, as the artifacts match an independent rebuild.
- 14:58: The Release Authority decided to **abort** the ceremony due to the incorrect key selection.

## Teardown

- 15:01: Outbound media: USB, model Kingston DataTraveler Exodia, serial `408D5C1EAE21F4A2`.
  ```sh
  mkdir -p /mnt/signatures
  mount /dev/sdc1 /mnt/signatures
  ls -al /mnt/signatures                  # the witness confirmed it was empty
  ```
- 15:02: The HSM operator's `script` session ended, and the transcripts were copied to the outbound media:
  ```sh
  exit
  cp signing.log time.tm /mnt/signatures
  sha256sum /mnt/signatures/*
  sync
  ls -al /mnt/signatures
  umount /mnt/signatures
  ```
  - `signing.log`: `0b5996709200aaaca79bc131fa7287abc0e01577952660e8e739a43a450c3ba7`
  - `time.tm`: `75f4b8a5de6275a42d39d572fc6b7c425ef8ef51759fe46e9ad687ca75f5e0dd`

  The witness reviewed `signing.log` and confirmed that it contains no sensitive data.
  The witness confirmed the outbound media contains only the two transcript files.
- 15:05: No signing operations (and no other operations besides `token list`) were performed on the HSM.
  The HSM session closed and the HSM was powered off.
- 15:06: The staging directory was deleted (`rm -rf ${STAGING_DIR}`) and `SIGN-WS-01` was powered off.
- 15:11: Equipment was re-sealed (with the seal serials checked by the witness):
  - HSM: tamper bag `TB-004541`.
  - Inbound media: tamper bag `TB-004542`.
  - `SIGN-WS-01`: seal `CS-00218`.
- 15:12: **Approval** (Release Authority): end of ceremony.
  The signing room was unsealed and the ceremony ended.

## Follow-Up

- 2026-10-20 15:30: The pre-sign release `PreRelease2026_10_20` was marked "do not use" in its release notes.
  Branch `release_2026_10_20` is abandoned.
- The ROM_EXT signing key misconfiguration is tracked in https://github.com/lowRISC/ot-sku/issues/4567890.
  A new pre-sign release and ceremony will follow once it is fixed.

## Sign-Off

The participants approve that this log is an accurate record of the ceremony:

- John Doe (Release Authority): approved.
- Abigail Reeves (HSM Operator): approved.
- Xin Yu (Witness & Evidence Recorder): approved.
````

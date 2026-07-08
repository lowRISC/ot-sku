# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

def _extra_repo_impl(rctx):
    src_dir = rctx.path(Label("@ot_provisioning_exts//:extra"))
    for p in src_dir.readdir():
        rctx.symlink(p, p.basename)

_extra_repo = repository_rule(
    implementation = _extra_repo_impl,
)

def _extra_impl(mctx):
    _extra_repo(name = "provisioning_exts_extra")

extra = module_extension(
    implementation = _extra_impl,
)

#!/bin/bash
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# This scripts builds and creates a release of pre-signing artefacts.
# The following environment variables must be set when running it:
# - OT_REPO: a path to the OpenTitan repository, already at the branch/commit
#            for the release
# - RELEASE_TAG: the tag to use for the release (will be used for the branch
#                and the Github release)
# - RELEASE_NOTES: release notes for Github
# - RELEASE_REPO: Github repository ([HOST/]OWNER/REPO) on which to release (optional)

set -x
set -e

OT_SKU_DIR=$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")
# Sanity check
if [ ! -f "$OT_SKU_DIR/MODULE.bazel" ]
then
    echo "Error: something is very wrong, I can't find the ot-sku repository"
    exit 1
fi
# Check environement variables
if [[ -z "$OT_REPO" ]]
then
    echo "Error: you must indicate where the OpenTitan repository is located using the OT_REPO env var"
    exit 1
fi
# Sanity check
BAZELISK=$(realpath "$OT_REPO/bazelisk.sh")
if [ ! -f "$BAZELISK" ]
then
    echo "Error: $OT_REPO does not seem to point to the OpenTitan repository"
    exit 1
fi
if [[ -z "$RELEASE_TAG" ]]
then
    echo "Error: you must indicate the release tag using the RELEASE_TAG env var"
    exit 1
fi
if [[ -z "$RELEASE_NOTES" ]]
then
    echo "Error: you must indicate the release notes using the RELEASE_NOTES env var"
    exit 1
fi

# We need to run all bazel commands with the provisioning_exts override.
# We also stamp all binaries for releases.
BAZEL_OPTS=(
    "--override_module=ot_provisioning_exts=$OT_SKU_DIR"
    "--stamp"
)

# Run everything in the OpenTitan directory because cquery results are relative to to there.
pushd "$OT_REPO"
# Build the presign perso firmware and rom_ext
"$BAZELISK" build "${BAZEL_OPTS[@]}" @provisioning_exts//open/perso:presign_perso  @provisioning_exts//open/rom_ext:presign_rom_ext
PRESIGN_PERSO=$(realpath "$("$BAZELISK" cquery "${BAZEL_OPTS[@]}" @provisioning_exts//open/perso:presign_perso)")
PRESIGN_ROM_EXT=$(realpath "$("$BAZELISK" cquery "${BAZEL_OPTS[@]}" @provisioning_exts//open/rom_ext:presign_rom_ext)")
popd

GH=gh
GH_ARGS=()
if [ -n "$RELEASE_REPO" ]
then
    GH_ARGS=("-R" "$RELEASE_REPO")
fi

# Release (pre-release) presign artifacts
"$GH" release create "${GH_ARGS[@]}" "$RELEASE_TAG" \
    -p -t "$RELEASE_TAG" \
    -n "$RELEASE_NOTES" \
    "$PRESIGN_PERSO" "$PRESIGN_ROM_EXT"

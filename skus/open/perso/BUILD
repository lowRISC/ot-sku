# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:signing.bzl", "offline_presigning_artifacts", "offline_signature_attach")
load("@lowrisc_opentitan//rules:signing.bzl", "signature_test")
load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load(
    "@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:provisioning_inputs.bzl",
    "disqualified_for_signing",
)
load("@provisioning_exts//:cfg.bzl", "EXT_EARLGREY_SKUS")

package(default_visibility = ["//visibility:public"])

SKU = "ot00"

offline_presigning_artifacts(
    name = "provisioning_{}".format(SKU),
    testonly = True,
    srcs = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_personalize_{}".format(SKU)],
    ecdsa_key = EXT_EARLGREY_SKUS[SKU]["ecdsa_key"],
    manifest = "@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:manifest_perso",
    spx_key = EXT_EARLGREY_SKUS[SKU]["spx_key"],
    tags = ["manual"],
)

# We want to publish pre-signed binaries in the presign package.
# Use a filegroup to capture the binary output group.
filegroup(
    name = "binaries_{}".format(SKU),
    testonly = True,
    srcs = ["provisioning_{}".format(SKU)],
    output_group = "binary",
    tags = ["manual"],
)

pkg_tar(
    name = "presign_perso",
    testonly = True,
    srcs = [
        "@provisioning_exts//shared/repo:presign_repo",
        ":provisioning_{}".format(SKU),
        ":binaries_{}".format(SKU),
    ],
    extension = "tar.xz",
    mode = "0644",
    tags = ["manual"],
)

offline_signature_attach(
    name = "signed",
    testonly = True,
    srcs = [
        "@provisioning_exts_extra//presign_perso:presigned",
    ],
    ecdsa_signatures = [
        "{}:ecdsa_signatures".format(EXT_EARLGREY_SKUS[SKU]["signature_prefix"]),
    ],
    spx_signatures = [
        "{}:spx_signatures".format(EXT_EARLGREY_SKUS[SKU]["signature_prefix"]),
    ],
    tags = ["manual"],
)

signature_test(
    name = "signature_test",
    srcs = [
        ":signed",
    ],
    ecdsa_key = EXT_EARLGREY_SKUS[SKU]["ecdsa_key"],
    spx_key = EXT_EARLGREY_SKUS[SKU]["spx_key"],
    tags = ["manual"],
)

pkg_tar(
    name = "perso_release",
    testonly = True,
    srcs = [
        ":signed",
        "@provisioning_exts//shared/repo:file_repo",
    ],
    extension = "tar.xz",
    mode = "0644",
    tags = ["manual"],
)

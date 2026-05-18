# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:const.bzl", "CONST", "hex")
load("@lowrisc_opentitan//rules:signing.bzl", "signature_test")
load("@lowrisc_opentitan//rules:manifest.bzl", "manifest")
load("@lowrisc_opentitan//rules:signing.bzl", "offline_presigning_artifacts", "offline_signature_attach")
load("@lowrisc_opentitan//rules/opentitan:defs.bzl", "opentitan_binary")
load(
    "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext:defs.bzl",
    "ROM_EXT_VERSION",
)
load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load("@provisioning_exts//:downstream.bzl", "DOWNSTREAM")

package(default_visibility = ["//visibility:public"])

manifest(d = {
    "name": "manifest_open",
    "identifier": hex(CONST.ROM_EXT),
    "version_major": ROM_EXT_VERSION.MAJOR,
    "version_minor": ROM_EXT_VERSION.MINOR,
    "security_version": DOWNSTREAM.SECURITY_VERSION,
    "secver_write": "true",
    "visibility": ["//visibility:public"],
})

# Apply -Oz and size optimization and use LLD when building the ROM_EXT.
ROM_EXT_BAZEL_FEATURES = [
    "minsize",
    "use_lld",
]

# To test that the prod-signed GB ROM_EXT boots on the FPGA, you need a bitstream
# with the gb keys pre-programmed into OTP.
# You can manually create such a bitstream (from the OpenTitan repo):
#
# bazel build //hw/bitstream/universal:splice \
#   --//hw/bitstream/universal:env=//hw/top_earlgrey:fpga_hyper310_rom_ext \
#   --//hw/bitstream/universal:otp=@provisioning_exts//open/otp/ot00:otp_img_prod_manuf_personalized

opentitan_binary(
    name = "rom_ext_dice_x509_fake_slot_virtual",
    ecdsa_key = select({
        "@lowrisc_opentitan//signing:test_keys": {"@lowrisc_opentitan//sw/device/silicon_creator/rom/keys/fake/ecdsa:ecdsa_keyset": "prod_key_0"},
        "//conditions:default": {"//open/keys/root:keyset": "gb00-earlgrey-a1-root-ecdsa-test-0"},
    }),
    exec_env = [
        "@lowrisc_opentitan//hw/top_earlgrey:silicon_creator",
        "@lowrisc_opentitan//hw/top_earlgrey:fpga_cw310",
        "@lowrisc_opentitan//hw/top_earlgrey:fpga_cw340",
    ],
    extra_bazel_features = ROM_EXT_BAZEL_FEATURES,
    linker_script = "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext:ld_slot_virtual",
    # In order to prevent the linker from prematurely discarding symbols, we
    # need to give the CRT library last.
    linkopts = [
        "$(location @lowrisc_opentitan//sw/device/silicon_creator/rom_ext:rom_ext_dice_x509)",
        "$(location @lowrisc_opentitan//sw/device/lib/crt)",
    ],
    manifest = ":manifest_open",
    spx_key = select({
        "@lowrisc_opentitan//signing:test_keys": {"@lowrisc_opentitan//sw/device/silicon_creator/rom/keys/fake/spx:spx_keyset": "prod_key_0"},
        "//conditions:default": {"//open/keys/root:spxset": "gb00-earlgrey-a1-root-spx-test-0"},
    }),
    deps = [
        # The owner C library is included only in the "fake" ROM_EXT,
        # as it is typically used to test FPGA flows and the FPGA doesn't
        # retain ownership information atis bitstream reloads.
        ":owner",
        "@lowrisc_opentitan//sw/device/lib/crt",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib:manifest_def",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/rescue:rescue_usbdfu",
        "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext:rom_ext_dice_x509",
        "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext/imm_section:main_section_dice_x509_slot_virtual",
    ],
)

opentitan_binary(
    name = "rom_ext_dice_x509_prod_slot_virtual",
    exec_env = [
        "@lowrisc_opentitan//hw/top_earlgrey:silicon_creator",
        "@lowrisc_opentitan//hw/top_earlgrey:fpga_cw310",
        "@lowrisc_opentitan//hw/top_earlgrey:fpga_cw340",
    ],
    extra_bazel_features = ROM_EXT_BAZEL_FEATURES,
    linker_script = "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext:ld_slot_virtual",
    linkopts = [
        "$(location @lowrisc_opentitan//sw/device/silicon_creator/rom_ext:rom_ext_dice_x509)",
        "$(location @lowrisc_opentitan//sw/device/lib/crt)",
    ],
    deps = [
        # The owner C library is excluded from the real ROM_EXT,
        # as chips maintain their ownership configuration in flash.
        "@lowrisc_opentitan//sw/device/lib/crt",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib:manifest_def",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/rescue:rescue_usbdfu",
        "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext:rom_ext_dice_x509",
        "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext/imm_section:main_section_dice_x509_slot_virtual",
    ],
)

genrule(
    name = "owner_bin",
    srcs = [
        "owner.json5",
        "//open/keys/owner:all_keys",
    ],
    outs = ["owner.bin"],
    # FIXME(ttrippel, cfrantz): The symlink is necessary because of the
    # inverted dependency relationship between lowRISC/opentitan and
    # ot-sku.  Remove after converting to bzlmod.
    cmd = """
        ln -s external/+hooks+provisioning_exts/open . && \
        $(execpath @lowrisc_opentitan//sw/host/opentitantool) --rcfile= \
            ownership config --input $(location :owner.json5) $@
    """,
    tools = ["@lowrisc_opentitan//sw/host/opentitantool"],
)

genrule(
    name = "owner_h",
    srcs = [
        ":owner_bin",
    ],
    outs = ["owner.h"],
    cmd = """
        $(execpath @lowrisc_opentitan//util/sh/scripts:bin2c.sh) \
                --input $(location :owner_bin) \
                --output $@ \
                --name open_owner
    """,
    tools = [
        "@lowrisc_opentitan//util/sh/scripts:bin2c.sh",
        "@lowrisc_opentitan//util/sh/scripts:c.hexdump",
    ],
)

cc_library(
    name = "owner",
    srcs = [
        "owner.c",
    ],
    textual_hdrs = [":owner_h"],
    deps = [
        "@lowrisc_opentitan//sw/device/silicon_creator/lib:boot_data",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/drivers:flash_ctrl",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership:datatypes",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership:owner_block",
    ],
    alwayslink = True,
)

offline_presigning_artifacts(
    name = "rom_ext",
    testonly = True,
    srcs = [":rom_ext_dice_x509_prod_slot_virtual"],
    ecdsa_key = {
        "//open/keys/root:keyset": "ot00-earlgrey-a2-root-ecdsa-prod-0",
    },
    manifest = ":manifest_open",
    spx_key = {
        "//open/keys/root:spxset": "ot00-earlgrey-a2-root-slhdsa-prod-0",
    },
    tags = ["manual"],
)

# We want to publish pre-signed binaries in the presign package.
# Use a filegroup to capture the binary output group.
filegroup(
    name = "binaries",
    testonly = True,
    srcs = [":rom_ext"],
    output_group = "binary",
    tags = ["manual"],
)

pkg_tar(
    name = "presign_rom_ext",
    testonly = True,
    srcs = [
        ":binaries",
        ":rom_ext",
        "@provisioning_exts//shared/repo:presign_repo",
    ],
    extension = "tar.xz",
    mode = "0644",
    tags = ["manual"],
)

offline_signature_attach(
    name = "signed",
    testonly = True,
    srcs = [
        "@provisioning_exts_extra//presign_rom_ext:presigned",
    ],
    ecdsa_signatures = [
        "//open/signatures/rom_ext:ecdsa_signatures",
    ],
    spx_signatures = [
        "//open/signatures/rom_ext:spx_signatures",
    ],
    tags = ["manual"],
)

signature_test(
    name = "signature_test",
    srcs = [
        ":signed",
    ],
    ecdsa_key = {
        "//open/keys/root:keyset": "ot00-earlgrey-a2-root-ecdsa-prod-0",
    },
    spx_key = {
        "//open/keys/root:spxset": "ot00-earlgrey-a2-root-slhdsa-prod-0",
    },
    tags = ["manual"],
)

pkg_tar(
    name = "rom_ext_release",
    testonly = True,
    srcs = [
        ":signed",
        "@provisioning_exts//shared/repo:file_repo",
    ],
    extension = "tar.xz",
    mode = "0644",
    tags = ["manual"],
)

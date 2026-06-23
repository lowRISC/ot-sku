# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:const.bzl", "CONST", "hex")
load("@lowrisc_opentitan//rules:manifest.bzl", "manifest")
load("@lowrisc_opentitan//rules:signing.bzl", "offline_presigning_artifacts", "offline_signature_attach")
load("@lowrisc_opentitan//rules/opentitan:defs.bzl", "opentitan_binary")
load(
    "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext:defs.bzl",
    "ROM_EXT_VERSION",
)
load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load("@provisioning_exts//:downstream.bzl", "DOWNSTREAM")
load("@lowrisc_opentitan//rules:ownership.bzl", "bin2c", "owner_block_binary")

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
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership:isfb_null",
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
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership:isfb_null",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/rescue:rescue_usbdfu",
        "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext:rom_ext_dice_x509",
        "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext/imm_section:main_section_dice_x509_slot_virtual",
    ],
)

offline_presigning_artifacts(
    name = "presigning",
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

pkg_tar(
    name = "digests",
    testonly = True,
    srcs = [":presigning"],
    mode = "0644",
    tags = ["manual"],
)

offline_signature_attach(
    name = "signed",
    testonly = True,
    srcs = [
        ":presigning",
    ],
    ecdsa_signatures = [
        "//open/signatures/rom_ext:ecdsa_signatures",
    ],
    spx_signatures = [
        "//open/signatures/rom_ext:spx_signatures",
    ],
    tags = ["manual"],
)

owner_block_binary(
    name = "owner_config_bin",
    src = "owner.json5",
    keys = [
        "//open/keys/owner:all_keys",
    ],
    relative_to = "//:BUILD.bazel",
)

bin2c(
    name = "owner_config",
    src = ":owner_config_bin",
    var_name = "open_owner",
)

cc_library(
    name = "owner",
    srcs = [
        "owner.c",
        ":owner_config",
    ],
    deps = [
        "@lowrisc_opentitan//sw/device/silicon_creator/lib:boot_data",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/drivers:flash_ctrl",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership:datatypes",
        "@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership:owner_block",
    ],
    alwayslink = True,
)

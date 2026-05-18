# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules/opentitan:cc.bzl", "exec_env_filegroup")
load("@lowrisc_opentitan//rules:files.bzl", "copy_files")
load("@lowrisc_opentitan//rules:signing.bzl", "signature_test")

package(default_visibility = ["//visibility:public"])

copy_files(
    name = "copy_signed",
    testonly = True,
    srcs = [
        "//open/rom_ext:signed",
    ],
    relative_to = ":BUILD",
    tags = ["manual"],
    workspace_env = "PROV_EXTS_DIR",
)

#signature_test(
#    name = "signature_test",
#    srcs = [
#        # TODO: reference files
#    ],
#    ecdsa_key = {
#        # TODO: reference keyset and keys
#    }
#)

exec_env_filegroup(
    name = "rom_ext_dice_x509_prod",
    testonly = True,
    exec_env = {
        "@lowrisc_opentitan//hw/top_earlgrey:fpga_hyper310_rom_with_fake_keys": "cw310",
        "@lowrisc_opentitan//hw/top_earlgrey:fpga_cw340_rom_with_fake_keys": "cw340",
        "@lowrisc_opentitan//hw/top_earlgrey:silicon_creator": "silicon",
    },
    files = {
        "rom_ext_dice_x509_prod_slot_virtual_fpga_cw310.signed.bin": "cw310",
        "rom_ext_dice_x509_prod_slot_virtual_fpga_cw340.signed.bin": "cw340",
        "rom_ext_dice_x509_prod_slot_virtual_silicon_creator.signed.bin": "silicon",
        "@provisioning_exts_extra//rom_ext_release:rom_ext_dice_x509_prod_slot_virtual_fpga_cw310.signed.bin": "cw340",
        "@provisioning_exts_extra//rom_ext_release:rom_ext_dice_x509_prod_slot_virtual_fpga_cw340.signed.bin": "cw310",
        "@provisioning_exts_extra//rom_ext_release:rom_ext_dice_x509_prod_slot_virtual_silicon_creator.signed.bin": "silicon",
    },
)

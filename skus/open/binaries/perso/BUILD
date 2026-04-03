# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:files.bzl", "copy_files")
load("@lowrisc_opentitan//rules:signing.bzl", "signature_test")
load("@lowrisc_opentitan//rules/opentitan:cc.bzl", "exec_env_filegroup")

package(default_visibility = ["//visibility:public"])

copy_files(
    name = "copy_signed",
    testonly = True,
    srcs = [
        "@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:signed",
    ],
    filter = [
        # TODO: filter relevant build targets from above label
        "ft_personalize_open",
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

#exec_env_filegroup(
#    name = "ft_personalize_fw",
#    testonly = True,
#    exec_env = {
#        # TODO: map execenvs to nicknames.
#        "@lowrisc_opentitan//hw/top_earlgrey:fpga_hyper310_rom_with_fake_keys": "cw310",
#        "@lowrisc_opentitan//hw/top_earlgrey:fpga_cw340_rom_with_fake_keys": "cw340",
#        "@lowrisc_opentitan//hw/top_earlgrey:silicon_creator": "silicon",
#    },
#    files = {
#        # TODO: replace with Owner FW when ready.
#        "@provisioning_exts//shared/owner_fw:ft_personalize_slot_virtual_fpga_cw310_rom_ext.signed.bin": "cw310",
#        "@provisioning_exts//shared/owner_fw:ft_personalize_slot_virtual_fpga_cw340_rom_ext.signed.bin": "cw340",
#        "@provisioning_exts//shared/owner_fw:ft_personalize_slot_virtual_silicon_owner_rom_ext.signed.bin": "silicon",
#    },
#)

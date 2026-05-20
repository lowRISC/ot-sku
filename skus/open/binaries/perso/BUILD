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
        "ft_personalize_ot00",
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
    name = "ft_personalize_ot00",
    testonly = True,
    exec_env = {
        "@lowrisc_opentitan//hw/top_earlgrey:fpga_hyper310_rom_with_fake_keys": "cw310",
        "@lowrisc_opentitan//hw/top_earlgrey:fpga_cw340_rom_with_fake_keys": "cw340",
        "@lowrisc_opentitan//hw/top_earlgrey:silicon_creator": "silicon",
    },
    # The "fake_keys" filenames are an unfortunate consequence of a historical
    # choice of naming convention.  They are, in fact, signed by offline HSM keys.
    files = {
        "@provisioning_exts_extra//perso_release:ft_personalize_ot00_fpga_cw340_rom_with_fake_keys.signed.bin": "cw340",
        "@provisioning_exts_extra//perso_release:ft_personalize_ot00_fpga_hyper310_rom_with_fake_keys.signed.bin": "cw310",
        "@provisioning_exts_extra//perso_release:ft_personalize_ot00_silicon_creator.signed.bin": "silicon",
    },
)

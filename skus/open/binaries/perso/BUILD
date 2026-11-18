# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:files.bzl", "copy_files")
# TODO: When signed `ot01` release binaries are available in `perso_release`,
# restore these loads and enable `signature_test`, `ft_personalize_ot01`, and
# `ft_flash_scramble_ot01`.
# load("@lowrisc_opentitan//rules:signing.bzl", "signature_test")
# load("@lowrisc_opentitan//rules/opentitan:cc.bzl", "exec_env_filegroup")
# load("@provisioning_exts//:cfg.bzl", "EXT_EARLGREY_SKUS")

package(default_visibility = ["//visibility:public"])

# TODO: we probably don't want to hardcode a specific SKU everywhere...
SKU = "ot01"

copy_files(
    name = "copy_signed",
    testonly = True,
    srcs = [
        "@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:signed",
    ],
    filter = [
        # TODO: filter relevant build targets from above label
        "ft_personalize_{}".format(SKU),
        "ft_flash_scramble_{}".format(SKU),
    ],
    relative_to = ":BUILD",
    tags = ["manual"],
    workspace_env = "PROV_EXTS_DIR",
)

# TODO: When signed `ot01` release binaries are available in `perso_release`,
# enable `signature_test`, `ft_personalize_ot01`, and `ft_flash_scramble_ot01`.
# signature_test(
#     name = "signature_test",
#     srcs = [
#         "@provisioning_exts_extra//perso_release:ft_flash_scramble_{}_fpga_cw340_rom_with_fake_keys.signed.bin".format(SKU),
#         "@provisioning_exts_extra//perso_release:ft_flash_scramble_{}_fpga_hyper310_rom_with_fake_keys.signed.bin".format(SKU),
#         "@provisioning_exts_extra//perso_release:ft_flash_scramble_{}_silicon_creator.signed.bin".format(SKU),
#         "@provisioning_exts_extra//perso_release:ft_personalize_{}_fpga_cw340_rom_with_fake_keys.signed.bin".format(SKU),
#         "@provisioning_exts_extra//perso_release:ft_personalize_{}_fpga_hyper310_rom_with_fake_keys.signed.bin".format(SKU),
#         "@provisioning_exts_extra//perso_release:ft_personalize_{}_silicon_creator.signed.bin".format(SKU),
#     ],
#     ecdsa_key = EXT_EARLGREY_SKUS[SKU]["ecdsa_key"],
#     spx_key = EXT_EARLGREY_SKUS[SKU]["spx_key"],
#     tags = ["manual"],
# )
#
# exec_env_filegroup(
#     name = "ft_personalize_{}".format(SKU),
#     testonly = True,
#     exec_env = {
#         "@lowrisc_opentitan//hw/top_earlgrey:fpga_hyper310_rom_with_fake_keys": "cw310",
#         "@lowrisc_opentitan//hw/top_earlgrey:fpga_cw340_rom_with_fake_keys": "cw340",
#         "@lowrisc_opentitan//hw/top_earlgrey:silicon_creator": "silicon",
#     },
#     # The "fake_keys" filenames are an unfortunate consequence of a historical
#     # choice of naming convention.  They are, in fact, signed by offline HSM keys.
#     files = {
#         "@provisioning_exts_extra//perso_release:ft_personalize_{}_fpga_cw340_rom_with_fake_keys.signed.bin".format(SKU): "cw340",
#         "@provisioning_exts_extra//perso_release:ft_personalize_{}_fpga_hyper310_rom_with_fake_keys.signed.bin".format(SKU): "cw310",
#         "@provisioning_exts_extra//perso_release:ft_personalize_{}_silicon_creator.signed.bin".format(SKU): "silicon",
#     },
# )
#
# exec_env_filegroup(
#     name = "ft_flash_scramble_{}".format(SKU),
#     testonly = True,
#     exec_env = {
#         "@lowrisc_opentitan//hw/top_earlgrey:fpga_hyper310_rom_with_fake_keys": "cw310",
#         "@lowrisc_opentitan//hw/top_earlgrey:fpga_cw340_rom_with_fake_keys": "cw340",
#         "@lowrisc_opentitan//hw/top_earlgrey:silicon_creator": "silicon",
#     },
#     # The "fake_keys" filenames are an unfortunate consequence of a historical
#     # choice of naming convention.  They are, in fact, signed by offline HSM keys.
#     files = {
#         "@provisioning_exts_extra//perso_release:ft_flash_scramble_{}_fpga_cw340_rom_with_fake_keys.signed.bin".format(SKU): "cw340",
#         "@provisioning_exts_extra//perso_release:ft_flash_scramble_{}_fpga_hyper310_rom_with_fake_keys.signed.bin".format(SKU): "cw310",
#         "@provisioning_exts_extra//perso_release:ft_flash_scramble_{}_silicon_creator.signed.bin".format(SKU): "silicon",
#     },
# )

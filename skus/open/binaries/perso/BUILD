# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:files.bzl", "copy_files")
load("@lowrisc_opentitan//rules:signing.bzl", "signature_test")
load("@lowrisc_opentitan//rules/opentitan:cc.bzl", "exec_env_filegroup")
load("@provisioning_exts//:cfg.bzl", "STANDARD_SKUS")

package(default_visibility = ["//visibility:public"])

# FIXME Should we delete this? Now that all binaries come from github releases,
# I don't think there is any use...
# copy_files(
#     name = "copy_signed",
#     testonly = True,
#     srcs = [
#         "@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:signed",
#     ],
#     filter = [
#         # TODO: filter relevant build targets from above label
#         "ft_personalize_{}".format(SKU),
#         "ft_flash_scramble_{}".format(SKU),
#     ],
#     relative_to = ":BUILD",
#     tags = ["manual"],
#     workspace_env = "PROV_EXTS_DIR",
# )

[
    signature_test(
        name = "signature_test",
        srcs = [
            "@provisioning_exts_extra//perso_release_{}:ft_flash_scramble_{}_fpga_cw340_rom_with_fake_keys.signed.bin".format(sku, sku),
            "@provisioning_exts_extra//perso_release_{}:ft_flash_scramble_{}_fpga_hyper310_rom_with_fake_keys.signed.bin".format(sku, sku),
            "@provisioning_exts_extra//perso_release_{}:ft_flash_scramble_{}_silicon_creator.signed.bin".format(sku, sku),
            "@provisioning_exts_extra//perso_release_{}:ft_personalize_{}_fpga_cw340_rom_with_fake_keys.signed.bin".format(sku, sku),
            "@provisioning_exts_extra//perso_release_{}:ft_personalize_{}_fpga_hyper310_rom_with_fake_keys.signed.bin".format(sku, sku),
            "@provisioning_exts_extra//perso_release_{}:ft_personalize_{}_silicon_creator.signed.bin".format(sku, sku),
        ],
        ecdsa_key = cfg["sku"]["ecdsa_key"],
        spx_key = cfg["sku"]["spx_key"],
        tags = ["manual"],
    )
    for (sku, cfg) in STANDARD_SKUS.items()
    if cfg.get("has_binaries", True)
]

# FIXME: there might be a point to be made about the release files containing those `exec_env_filegroup`
# directly in the BUILD file. Currently, this leads to a lot of useless duplication
[
    exec_env_filegroup(
        name = "ft_personalize_{}".format(sku),
        testonly = True,
        exec_env = {
            "@lowrisc_opentitan//hw/top_earlgrey:fpga_hyper310_rom_with_fake_keys": "cw310",
            "@lowrisc_opentitan//hw/top_earlgrey:fpga_cw340_rom_with_fake_keys": "cw340",
            "@lowrisc_opentitan//hw/top_earlgrey:silicon_creator": "silicon",
        },
        # The "fake_keys" filenames are an unfortunate consequence of a historical
        # choice of naming convention.  They are, in fact, signed by offline HSM keys.
        files = {
            "@provisioning_exts_extra//perso_release_{}:ft_personalize_{}_fpga_cw340_rom_with_fake_keys.signed.bin".format(sku, sku): "cw340",
            "@provisioning_exts_extra//perso_release_{}:ft_personalize_{}_fpga_hyper310_rom_with_fake_keys.signed.bin".format(sku, sku): "cw310",
            "@provisioning_exts_extra//perso_release_{}:ft_personalize_{}_silicon_creator.signed.bin".format(sku, sku): "silicon",
        },
    )
    for (sku, cfg) in STANDARD_SKUS.items()
    if cfg.get("has_binaries", True)
]

# FIXME same
[
    exec_env_filegroup(
        name = "ft_flash_scramble_{}".format(sku),
        testonly = True,
        exec_env = {
            "@lowrisc_opentitan//hw/top_earlgrey:fpga_hyper310_rom_with_fake_keys": "cw310",
            "@lowrisc_opentitan//hw/top_earlgrey:fpga_cw340_rom_with_fake_keys": "cw340",
            "@lowrisc_opentitan//hw/top_earlgrey:silicon_creator": "silicon",
        },
        # The "fake_keys" filenames are an unfortunate consequence of a historical
        # choice of naming convention.  They are, in fact, signed by offline HSM keys.
        files = {
            "@provisioning_exts_extra//perso_release_{}:ft_flash_scramble_{}_fpga_cw340_rom_with_fake_keys.signed.bin".format(sku, sku): "cw340",
            "@provisioning_exts_extra//perso_release_{}:ft_flash_scramble_{}_fpga_hyper310_rom_with_fake_keys.signed.bin".format(sku, sku): "cw310",
            "@provisioning_exts_extra//perso_release_{}:ft_flash_scramble_{}_silicon_creator.signed.bin".format(sku, sku): "silicon",
        },
    )
    for (sku, cfg) in STANDARD_SKUS.items()
    if cfg.get("has_binaries", True)
]

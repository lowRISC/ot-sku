# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules/opentitan:cc.bzl", "exec_env_filegroup")
load("@lowrisc_opentitan//rules:files.bzl", "copy_files")
load("@lowrisc_opentitan//rules:signing.bzl", "signature_test")
load("@provisioning_exts//:cfg.bzl", "STANDARD_SKUS")

package(default_visibility = ["//visibility:public"])

# FIXME Should we delete this? Now that all binaries come from github releases,
# I don't think there is any use...
# copy_files(
#     name = "copy_signed",
#     testonly = True,
#     srcs = [
#         "//open/rom_ext:signed",
#     ],
#     relative_to = ":BUILD",
#     tags = ["manual"],
#     workspace_env = "PROV_EXTS_DIR",
# )

[
    signature_test(
        name = "signature_test_{}".format(sku),
        srcs = [
            "@provisioning_exts_extra//rom_ext_release:rom_ext_dice_x509_prod_slot_virtual_fpga_cw310.signed.bin",
            "@provisioning_exts_extra//rom_ext_release:rom_ext_dice_x509_prod_slot_virtual_fpga_cw340.signed.bin",
            "@provisioning_exts_extra//rom_ext_release:rom_ext_dice_x509_prod_slot_virtual_silicon_creator.signed.bin",
        ],
        ecdsa_key = cfg["sku"]["ecdsa_key"],
        spx_key = cfg["sku"]["spx_key"],
        tags = ["manual"],
    )
    for (sku, cfg) in STANDARD_SKUS.items()
    if cfg.get("has_binaries", True)
]

[
    # FIXME: should we remove dice_x509_prod from the name?
    # FIXME: there might be a point to be made about the release files containing those `exec_env_filegroup`
    # directly in the BUILD file. Currently, this leads to a lot of useless duplication
    exec_env_filegroup(
        name = "rom_ext_dice_x509_prod_{}".format(sku),
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
            "@provisioning_exts_extra//rom_ext_release_{}:rom_ext_dice_x509_prod_slot_virtual_fpga_cw310.signed.bin".format(sku): "cw310",
            "@provisioning_exts_extra//rom_ext_release_{}:rom_ext_dice_x509_prod_slot_virtual_fpga_cw340.signed.bin".format(sku): "cw340",
            "@provisioning_exts_extra//rom_ext_release_{}:rom_ext_dice_x509_prod_slot_virtual_silicon_creator.signed.bin".format(sku): "silicon",
        },
    )
    for (sku, cfg) in STANDARD_SKUS.items()
    if cfg.get("has_binaries", True)
]

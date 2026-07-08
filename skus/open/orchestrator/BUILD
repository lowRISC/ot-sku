# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:sku.bzl", "sku_cert", "sku_cfg")

package(default_visibility = ["//visibility:public"])

sku_cert(
    name = "ot00_dice_ca",
    certificate = "//open/keys/ca:dice_ca.pem",
    key = "nuvoton-ot00-ca-ecdsa-0",
    key_id = "0xDBF5003E7CB9EEB524780CCE766E661CFB01C7B2",
    key_type = "Token",
)

sku_cfg(
    name = "emulation_open",
    testonly = True,
    dice_ca = "@lowrisc_opentitan//sw/host/provisioning/orchestrator/configs/skus:emulation_dice_ca",
    ext_ca = "@lowrisc_opentitan//sw/host/provisioning/orchestrator/configs/skus:emulation_ext_ca",
    otp = "em00",
    owner_fw_boot_str = "Bare metal PASS!",
    package = "npcr13",
    perso_bin_suffix = "ft_personalize_{sku}_{target}.prod_key_0.prod_key_0.signed.bin",
    perso_bins = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_personalize_emulation_open"],
    product = "earlgrey_a2",
    si_creator = "nuvoton",
    sku_name = "emulation_open",
    target_lc_state = "prod",
    token_encrypt_key = "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/fake:rma_unlock_enc_rsa3072.pub.der",
)

sku_cfg(
    name = "ot00_staging",
    testonly = True,
    dice_ca = "@lowrisc_opentitan//sw/host/provisioning/orchestrator/configs/skus:emulation_dice_ca",
    otp = "ot00",
    owner_fw_boot_str = "info: rescue protocol U",
    package = "npcr13",
    perso_bin_suffix = "ft_personalize_{sku}_{target}.signed.bin",
    perso_bins = ["//open/binaries/perso:ft_personalize_ot00"],
    product = "earlgrey_a2",
    si_creator = "nuvoton",
    sku_name = "ot00",
    target_lc_state = "prod",
    # TODO(ot-sku#13): Update this key to a real key after keygen.
    token_encrypt_key = "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/sival:rma_unlock_enc_rsa3072.pub.der",
)

sku_cfg(
    name = "ot00",
    testonly = True,
    dice_ca = ":ot00_dice_ca",
    otp = "ot00",
    owner_fw_boot_str = "info: rescue protocol U",
    package = "npcr13",
    perso_bin_suffix = "ft_personalize_{sku}_{target}.signed.bin",
    perso_bins = ["//open/binaries/perso:ft_personalize_ot00"],
    product = "earlgrey_a2",
    si_creator = "nuvoton",
    sku_name = "ot00",
    target_lc_state = "prod",
    # TODO(ot-sku#13): Update this key to a real key after keygen.
    token_encrypt_key = "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/sival:rma_unlock_enc_rsa3072.pub.der",
)

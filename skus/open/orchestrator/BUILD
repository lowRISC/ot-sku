# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:sku.bzl", "sku_cert", "sku_cfg")

package(default_visibility = ["//visibility:public"])

sku_cert(
    name = "ot00_dice_ca",
    certificate = "//open/keys/ca:dice_ca.pem",
    key = "nuvoton-ot00-ca-ecdsa-0",
    key_id = "0x7CDDE6D1C7C7B3A87233A3EF92FD2159A09308DC",
    key_type = "Token",
)

# TODO(ot-sku#13): Update to real OT01 CA certificate and key after keygen.
sku_cert(
    name = "ot01_dice_ca",
    certificate = "//open/keys/ca:dice_ca.pem",
    key = "nuvoton-ot00-ca-ecdsa-0",
    key_id = "0x7CDDE6D1C7C7B3A87233A3EF92FD2159A09308DC",
    key_type = "Token",
)

sku_cfg(
    name = "emulation_open",
    testonly = True,
    dice_ca = "@lowrisc_opentitan//sw/host/provisioning/orchestrator/configs/skus:emulation_dice_ca",
    ext_ca = "@lowrisc_opentitan//sw/host/provisioning/orchestrator/configs/skus:emulation_ext_ca",
    otp = "oe00",
    owner_fw_boot_str = "Bare metal PASS!",
    package = "npcr13",
    perso_bin_suffix = "ft_personalize_{sku}_{target}.prod_key_0.prod_key_0.signed.bin",
    perso_bins = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_personalize_emulation_open"],
    product = "earlgrey_a2",
    scrambling_bin_suffix = "ft_flash_scramble_{sku}_{target}.prod_key_0.prod_key_0.signed.bin",
    scrambling_bins = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_flash_scramble_emulation_open"],
    si_creator = "nuvoton",
    sku_name = "emulation_open",
    target_lc_state = "prod",
    token_encrypt_key = "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/fake:rma_unlock_enc_rsa3072.pub.der",
)

sku_cfg(
    name = "emulation_ot01",
    testonly = True,
    dice_ca = "@lowrisc_opentitan//sw/host/provisioning/orchestrator/configs/skus:emulation_dice_ca",
    ext_ca = "@lowrisc_opentitan//sw/host/provisioning/orchestrator/configs/skus:emulation_ext_ca",
    otp = "oe01",
    owner_fw_boot_str = "Bare metal PASS!",
    package = "npcr13",
    perso_bin_suffix = "ft_personalize_{sku}_{target}.prod_key_0.prod_key_0.signed.bin",
    perso_bins = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_personalize_emulation_ot01"],
    product = "earlgrey_a2",
    scrambling_bin_suffix = "ft_flash_scramble_{sku}_{target}.prod_key_0.prod_key_0.signed.bin",
    scrambling_bins = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_flash_scramble_emulation_ot01"],
    si_creator = "nuvoton",
    sku_name = "emulation_ot01",
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
    scrambling_bin_suffix = "ft_flash_scramble_{sku}_{target}.signed.bin",
    scrambling_bins = ["//open/binaries/perso:ft_flash_scramble_ot00"],
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
    scrambling_bin_suffix = "ft_flash_scramble_{sku}_{target}.signed.bin",
    scrambling_bins = ["//open/binaries/perso:ft_flash_scramble_ot00"],
    si_creator = "nuvoton",
    sku_name = "ot00",
    target_lc_state = "prod",
    # TODO(ot-sku#13): Update this key to a real key after keygen.
    token_encrypt_key = "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/sival:rma_unlock_enc_rsa3072.pub.der",
)

sku_cfg(
    name = "ot01_staging",
    testonly = True,
    dice_ca = "@lowrisc_opentitan//sw/host/provisioning/orchestrator/configs/skus:emulation_dice_ca",
    otp = "ot01",
    owner_fw_boot_str = "info: rescue protocol U",
    package = "npcr13",
    # TODO: When signed `ot01` release binaries are available, switch to
    # `//open/binaries/perso:ft_{personalize,flash_scramble}_ot01` with `.signed.bin` suffixes.
    perso_bin_suffix = "ft_personalize_{sku}_{target}.prod_key_0.prod_key_0.signed.bin",
    perso_bins = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_personalize_ot01"],
    product = "earlgrey_a2",
    scrambling_bin_suffix = "ft_flash_scramble_{sku}_{target}.prod_key_0.prod_key_0.signed.bin",
    scrambling_bins = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_flash_scramble_ot01"],
    si_creator = "nuvoton",
    sku_name = "ot01",
    target_lc_state = "prod",
    # TODO(ot-sku#13): Update this key to a real key after keygen.
    token_encrypt_key = "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/sival:rma_unlock_enc_rsa3072.pub.der",
)

sku_cfg(
    name = "ot01",
    testonly = True,
    dice_ca = ":ot01_dice_ca",
    otp = "ot01",
    owner_fw_boot_str = "info: rescue protocol U",
    package = "npcr13",
    # TODO: When signed `ot01` release binaries are available, switch to
    # `//open/binaries/perso:ft_{personalize,flash_scramble}_ot01` with `.signed.bin` suffixes.
    perso_bin_suffix = "ft_personalize_{sku}_{target}.prod_key_0.prod_key_0.signed.bin",
    perso_bins = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_personalize_ot01"],
    product = "earlgrey_a2",
    scrambling_bin_suffix = "ft_flash_scramble_{sku}_{target}.prod_key_0.prod_key_0.signed.bin",
    scrambling_bins = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_flash_scramble_ot01"],
    si_creator = "nuvoton",
    sku_name = "ot01",
    target_lc_state = "prod",
    # TODO(ot-sku#13): Update this key to a real key after keygen.
    token_encrypt_key = "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/sival:rma_unlock_enc_rsa3072.pub.der",
)

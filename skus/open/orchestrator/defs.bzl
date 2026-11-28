# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:sku.bzl", "sku_cert", "sku_cfg")

def standard_sku_cfg(name, cfg):
    """
    Define three `sku_cfg` targets, using information from `STANDARD_SKUS`:
    - <name>: the configuration of the SKU
    - <name>_staging: the configuration of the staging SKU which uses a fake CA.
    - <name>_emulation: same as staging but also uses fake signing keys and a different owner firmware.

    If `cfg["has_binaries"]` is set to False, only the emulation config will be created.
    """
    sku_cert_cfg = {}
    sku_cert_cfg.update(
        dice_ca = cfg["dice_ca"],
        otp = cfg["sku"]["otp"],
        # TODO document
        owner_fw_boot_str = "info: rescue protocol U",
        package = "npcr13",
        # TODO document
        perso_bin_suffix = "ft_personalize_{sku}_{target}.signed.bin",
        perso_bins = ["//open/binaries/perso:ft_personalize_{}".format(name)],
        # FIXME clarify this field.
        product = "earlgrey_a2",
        # TODO document
        scrambling_bin_suffix = "ft_flash_scramble_{sku}_{target}.signed.bin",
        scrambling_bins = ["//open/binaries/perso:ft_flash_scramble_{}".format(name)],
        # FIXME clarify this field
        si_creator = "nuvoton",
        sku_name = name,
        target_lc_state = "prod",
        # TODO(ot-sku#13): Update this key to a real key after keygen.
        # FIXME clarify this field.
        token_encrypt_key = "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/sival:rma_unlock_enc_rsa3072.pub.der",
    )

    has_binaries = cfg.get("has_binaries", True)
    if has_binaries:
        sku_cfg(
            name = name,
            testonly = True,
            **sku_cert_cfg
        )

    sku_cert_cfg.update(
        dice_ca = "@lowrisc_opentitan//sw/host/provisioning/orchestrator/configs/skus:emulation_dice_ca",
    )

    if has_binaries:
        sku_cfg(
            name = "{}_staging".format(name),
            testonly = True,
            **sku_cert_cfg
        )

    sku_cert_cfg.update(
        ext_ca = "@lowrisc_opentitan//sw/host/provisioning/orchestrator/configs/skus:emulation_ext_ca",
        otp = cfg["emulation_otp"],
        owner_fw_boot_str = "Bare metal PASS!",
        perso_bin_suffix = "ft_personalize_{sku}_{target}.prod_key_0.prod_key_0.signed.bin",
        perso_bins = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_personalize_{}_emulation".format(name)],
        scrambling_bin_suffix = "ft_flash_scramble_{sku}_{target}.prod_key_0.prod_key_0.signed.bin",
        scrambling_bins = ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:ft_flash_scramble_{}_emulation".format(name)],
        sku_name = "{}_emulation".format(name),
        token_encrypt_key = "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/fake:rma_unlock_enc_rsa3072.pub.der",
    )

    sku_cfg(
        name = "{}_emulation".format(name),
        testonly = True,
        **sku_cert_cfg
    )

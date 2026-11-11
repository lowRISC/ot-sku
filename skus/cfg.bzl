# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

EXT_EARLGREY_OTP_CFGS = {
    "ot01": "@provisioning_exts//open/otp/ot01:otp_consts",
    "oe01": "@provisioning_exts//open/otp/ot01_emulation:otp_consts",
}

# TODO: Migrate these SKUs to the `ROM_EXT` and certificate libraries for DICE ML-DSA.
EXT_EARLGREY_SKUS = {
    ############################################################################
    # Emulation SKUs
    ############################################################################
    "emulation_open": {
        "otp": "oe01",
        "ca_data": "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/fake:ca_data",
        "dice_format": "x509",
        "host_ext_libs": ["@provisioning_exts//open:ft_ext_lib"],
        "device_ext_libs": ["@provisioning_exts//open:personalize_fw_ext"],
        "ownership_libs": ["@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership:test_owner"],
        "rom_ext": "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext:rom_ext_dice_x509_slot_virtual",
        "owner_fw": "@lowrisc_opentitan//sw/device/silicon_owner/bare_metal:bare_metal_slot_b",
        "ecdsa_key": {"@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership/keys/fake:ecdsa_keyset": "app_prod_0"},
        "spx_key": {"@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership/keys/fake:slh_dsa_keyset": "app_prod_0"},
        "signature_prefix": None,
        "orchestrator_cfg": "@provisioning_exts//open/orchestrator:emulation_open",
    },

    ############################################################################
    # Open Market SKUs
    ############################################################################
    # Same as ot01 SKU below, except uses fake CA for testing in CI.
    "ot01_staging": {
        "otp": "ot01",
        # TODO: use a fake CA within `ot-sku` so that CI can catch a mismatch between the
        # UDS template and CA subject once these are changed from the upstream values.
        "ca_data": "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/fake:ca_data",
        "dice_format": "x509",
        "uds_template": "@provisioning_exts//open/cert:uds_ot01.hjson",
        "host_ext_libs": ["@provisioning_exts//open:ft_ext_lib"],
        "device_ext_libs": ["@provisioning_exts//open:personalize_fw_ext"],
        "ownership_libs": ["@provisioning_exts//open/rom_ext:owner"],
        "rom_ext": "@provisioning_exts//open/binaries/rom_ext:rom_ext_dice_x509_prod",
        "owner_fw": None,
        "ecdsa_key": {"@provisioning_exts//open/keys/root:keyset": "ot00-earlgrey-a2-root-ecdsa-prod-0"},
        "spx_key": {"@provisioning_exts//open/keys/root:spxset": "ot00-earlgrey-a2-root-slhdsa-prod-0"},
        "signature_prefix": "@provisioning_exts//open/signatures/perso",
        # TODO: When signed `ot01` release binaries are available, enable `scrambling_bin` and `perso_bin`.
        # "scrambling_bin": "@provisioning_exts//open/binaries/perso:ft_flash_scramble_ot01",
        # "perso_bin": "@provisioning_exts//open/binaries/perso:ft_personalize_ot01",
        "orchestrator_cfg": "@provisioning_exts//open/orchestrator:ot01_staging",
        # TODO: When signed `ot01` binaries are available, set `offline` to `False`.
        "offline": True,
    },
    "ot01": {
        "otp": "ot01",
        "ca_data": "@provisioning_exts//open/keys/ca:ca_data",
        "dice_format": "x509",
        "uds_template": "@provisioning_exts//open/cert:uds_ot01.hjson",
        "host_ext_libs": ["@provisioning_exts//open:ft_ext_lib"],
        "device_ext_libs": ["@provisioning_exts//open:personalize_fw_ext"],
        "ownership_libs": ["@provisioning_exts//open/rom_ext:owner"],
        "rom_ext": "@provisioning_exts//open/binaries/rom_ext:rom_ext_dice_x509_prod",
        "owner_fw": None,
        "ecdsa_key": {"@provisioning_exts//open/keys/root:keyset": "ot00-earlgrey-a2-root-ecdsa-prod-0"},
        "spx_key": {"@provisioning_exts//open/keys/root:spxset": "ot00-earlgrey-a2-root-slhdsa-prod-0"},
        "signature_prefix": "@provisioning_exts//open/signatures/perso",
        # TODO: When signed `ot01` release binaries are available, enable `scrambling_bin` and `perso_bin`.
        # "scrambling_bin": "@provisioning_exts//open/binaries/perso:ft_flash_scramble_ot01",
        # "perso_bin": "@provisioning_exts//open/binaries/perso:ft_personalize_ot01",
        "orchestrator_cfg": "@provisioning_exts//open/orchestrator:ot01",
        "offline": True,
    },
}

EXT_EXEC_ENV_SILICON_ROM_EXT = {
    #    "@provisioning_exts//shared/exec_env:silicon_owner_gb_rom_ext": None,
}

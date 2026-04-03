# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

EXT_EARLGREY_OTP_CFGS = {
    "ot00": "@provisioning_exts//open/otp/ot00:otp_consts",
}

EXT_EARLGREY_SKUS = {
    ############################################################################
    # Emulation SKUs
    ############################################################################
    "emulation_open": {
        "otp": "em00",
        "ca_data": "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/fake:ca_data",
        "dice_libs": ["@lowrisc_opentitan//sw/device/silicon_creator/lib/cert:dice"],
        "host_ext_libs": ["@provisioning_exts//open:ft_ext_lib"],
        "device_ext_libs": ["@provisioning_exts//open:personalize_fw_ext"],
        "ownership_libs": ["@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership:test_owner"],
        "rom_ext": "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext:rom_ext_dice_x509_slot_virtual",
        "owner_fw": "@lowrisc_opentitan//sw/device/silicon_owner/bare_metal:bare_metal_slot_b",
        "ecdsa_key": {},
        "spx_key": {},
        "signature_prefix": None,
        "orchestrator_cfg": "@provisioning_exts//open/orchestrator:emulation_open.hjson",
    },

    ############################################################################
    # Open Market SKUs
    ############################################################################
    # Same as ot00 SKU below, except uses fake CA for testing in CI.

    # TODO: enable these after signing binaries
    # TODO: figure out how to manage binares as a release archive
    #
    #"ot00_staging": {
    #    "otp": "ot00",
    #    "ca_data": "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/fake:ca_data",
    #    "dice_libs": ["@lowrisc_opentitan//sw/device/silicon_creator/lib/cert:dice"],
    #    "host_ext_libs": ["@provisioning_exts//open:ft_ext_lib"],
    #    "device_ext_libs": ["@provisioning_exts//open:personalize_fw_ext"],
    #    "ownership_libs": ["@provisioning_exts//open/rom_ext:owner"],
    #    "rom_ext": "@provisioning_exts//open/binaries/rom_ext:rom_ext_dice_x509_prod",
    #    "owner_fw": "@provisioning_exts//open/binaries/owner_fw:ti_owner_fw",
    #    "ecdsa_key": {"@provisioning_exts//open/keys/root:keyset": "ot00-earlgrey-a2-root-ecdsa-prod-0"},
    #    "spx_key": {"@provisioning_exts//open/keys/root:spxset": "ot00-earlgrey-a2-root-slhdsa-prod-0"},
    #    "signature_prefix": "@provisioning_exts//open/signatures/perso",
    #    "perso_bin": "@provisioning_exts//open/binaries/perso:ft_personalize_ot00",
    #    "orchestrator_cfg": "@provisioning_exts//open/orchestrator:ot00_staging.hjson",
    #    "offline": False,
    #},
    #"ot00": {
    #    "otp": "ot00",
    #    "ca_data": "@provisioning_exts//shared/keys/ca:ca_data",
    #    "dice_libs": ["@lowrisc_opentitan//sw/device/silicon_creator/lib/cert:dice"],
    #    "host_ext_libs": ["@provisioning_exts//open:ft_ext_lib"],
    #    "device_ext_libs": ["@provisioning_exts//open:personalize_fw_ext"],
    #    "ownership_libs": ["@provisioning_exts//open/rom_ext:owner"],
    #    "rom_ext": "@provisioning_exts//open/binaries/rom_ext:rom_ext_dice_x509_prod",
    #    "owner_fw": "@provisioning_exts//open/binaries/owner_fw:ti_owner_fw",
    #    "ecdsa_key": {"@provisioning_exts//open/keys/root:keyset": "ot00-earlgrey-a2-root-ecdsa-prod-0"},
    #    "spx_key": {"@provisioning_exts//open/keys/root:spxset": "ot00-earlgrey-a2-root-slhdsa-prod-0"},
    #    "signature_prefix": "@provisioning_exts//open/signatures/perso",
    #    "perso_bin": "@provisioning_exts//open/binaries/perso:ft_personalize_ot00",
    #    "orchestrator_cfg": "@provisioning_exts//open/orchestrator:ot00.hjson",
    #    "offline": True,
    #},
}

EXT_EXEC_ENV_SILICON_ROM_EXT = {
    "@provisioning_exts//shared/exec_env:silicon_owner_gb_rom_ext": None,
}

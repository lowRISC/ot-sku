# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

EXT_EARLGREY_OTP_CFGS = {
    "ot01": "@provisioning_exts//open/otp/ot01:otp_consts",
    "oe01": "@provisioning_exts//open/otp/ot01_emulation:otp_consts",
}

STANDARD_SKUS = {
    # See documentation in standard_sku, a dictionary with the following keys:
    # - sku: SKU configuration, as documented in
    #   https://github.com/lowRISC/opentitan/blob/earlgrey_1.0.0/sw/device/silicon_creator/manuf/extensions/repo/cfg.bzl
    # - emulation_otp: used for the emulation SKU to replace the `otp` field in `sku`.
    # - dice_ca: label of the SKU certificate information, defined using `sku_cert`.
    # - token_encrypt_key: FIXME clarify
    # - has_binaries: set to False if the sku does not yet have binaries in `extension.bzl`'s `_ARCHIVES`
    "ot01": {
        "sku": {
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
            "orchestrator_cfg": "@provisioning_exts//open/orchestrator:ot01",
        },
        "emulation_otp": "oe01",
        "dice_ca": "@provisioning_exts//open/orchestrator:ot01_dice_ca",
        "token_encrypt_key": "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/sival:rma_unlock_enc_rsa3072.pub.der",
        "has_binaries": False,
    },
}

def standard_sku(name, cfg):
    """
    Return a dictionary of three(*) SKUs:
    - <name>:
      The SKU as described in `cfg["sku"]`, see
      https://github.com/lowRISC/opentitan/blob/earlgrey_1.0.0/sw/device/silicon_creator/manuf/extensions/repo/cfg.bzl
      Binaries are signed offline and integrated via a GitHub Release flow (see create_release.md), which they are then sourced from.
      The DICE CA key for endorsing the Unique Device Secret (UDS) is private - known only to the manufacturer - and so this SKU cannot
      be tested in online FPGA flows.

    - <name>_staging:
       It is the exact same as <name>, except that it can be used in online FPGA flows, as it uses OpenTitan's `emulation_dice_ca`,
       using a fake CA key that is checked into upstream OpenTitan for UDS endorsement.
       This allows for the full manufacturing flow to be tested on an FPGA, using the same signed binaries that are sourced from GitHub Releases
       via an offline signing ceremony.

    - <name>_emulation:
       Its intention is to use the same OTP configuration as the real open-market SKU (except for the root keys), instead making use of the fake
       signing keys defined in `opentitan` so that it can be easily used to test signing flows without requiring any offline step.
       This SKU uses `cfg["emulation_otp"]` for the `otp` SKU parameter and `@provisioning_exts//open/orchestrator:emulation_<name>` for
       the orchestrator configuration.

    (*) If `has_binaries` is set to False in `cfg`, then both the staging and emulation SKU will be removed, and only the emulation SKU will be
    returned. This setting should be used when creating a new SKU which does not yet have signed binaries declared in `_ARCHIVES`
    in `extension.bzl`.
    """

    # Unless overriden by the sku configuration, we use the scrambling and perso binaries setup automatically.
    config = {
        "scrambling_bin": "@provisioning_exts//open/binaries/perso:ft_flash_scramble_{}".format(name),
        "perso_bin": "@provisioning_exts//open/binaries/perso:ft_personalize_{}".format(name),
        "offline": True,
    } | cfg["sku"]

    staging_cfg = config | {
        # TODO: use a fake CA within `ot-sku` so that CI can catch a mismatch between the
        # UDS template and CA subject once these are changed from the upstream values.
        "ca_data": "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/fake:ca_data",
        "orchestrator_cfg": "@provisioning_exts//open/orchestrator:{}_staging".format(name),
        "offline": False,
    }

    emulation_cfg = config | {
        "otp": cfg["emulation_otp"],
        "ca_data": "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/fake:ca_data",
        "ownership_libs": ["@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership:test_owner"],
        "rom_ext": "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext:rom_ext_dice_x509_slot_virtual",
        "owner_fw": "@lowrisc_opentitan//sw/device/silicon_owner/bare_metal:bare_metal_slot_b",
        "ecdsa_key": {"@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership/keys/fake:ecdsa_keyset": "app_prod_0"},
        "spx_key": {"@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership/keys/fake:slh_dsa_keyset": "app_prod_0"},
        "signature_prefix": None,
        "orchestrator_cfg": "@provisioning_exts//open/orchestrator:{}_emulation".format(name),
        "offline": False,
    }

    return ({
        name: config,
        "{}_staging".format(name): staging_cfg,
    } if not cfg.get("has_binaries", True) else {}) | {
        "{}_emulation".format(name): emulation_cfg,
    }

EXT_EARLGREY_SKUS = {
    ############################################################################
    # Emulation SKUs
    ############################################################################
    # This SKU is for testing purpose only, notably in CI.
    "fake_do_not_use": {
        # FIXME We need to create an emulation OTP configuration which is independent of ot01 and stable for testing.
        "otp": "oe01",
        "ca_data": "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/fake:ca_data",
        "dice_format": "x509",
        "host_ext_libs": ["@lowrisc_opentitan//sw/host/provisioning/ft_ext_lib:default_ft_ext_lib"],
        "device_ext_libs": ["@lowrisc_opentitan//sw/device/silicon_creator/manuf/default:default_perso_fw_ext"],
        "ownership_libs": ["//sw/device/silicon_creator/lib/ownership:test_owner"],
        "rom_ext": "@lowrisc_opentitan//sw/device/silicon_creator/rom_ext:rom_ext_dice_x509_slot_virtual",
        "owner_fw": "@lowrisc_opentitan//sw/device/silicon_owner/bare_metal:bare_metal_slot_b",
        "ecdsa_key": {"@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership/keys/fake:ecdsa_keyset": "app_prod_0"},
        "spx_key": {"@lowrisc_opentitan//sw/device/silicon_creator/lib/ownership/keys/fake:slh_dsa_keyset": "app_prod_0"},
        "signature_prefix": None,
        # FIXME We need to create an emulation OTP configuration which is independent of ot01 and stable for testing.
        "orchestrator_cfg": "@provisioning_exts//open/orchestrator:ot01_emulation",
    },
} | {
    sku_name: config
    for (sku, std_cfg) in STANDARD_SKUS.items()
    for (sku_name, config) in standard_sku(sku, std_cfg).items()
}

EXT_EXEC_ENV_SILICON_ROM_EXT = {
    #    "@provisioning_exts//shared/exec_env:silicon_owner_gb_rom_ext": None,
}

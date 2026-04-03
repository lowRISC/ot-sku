# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# SKU: OT__.
# Version: 02.

load(
    "@lowrisc_opentitan//rules:const.bzl",
    "CONST",
    "EARLGREY_ALERTS",
    "EARLGREY_LOC_ALERTS",
)
load(
    "@lowrisc_opentitan//rules:otp.bzl",
    "otp_alert_classification",
    "otp_alert_digest",
    "otp_hex",
    "otp_json",
    "otp_partition",
    "otp_per_class_bytes",
    "otp_per_class_ints",
    "otp_per_class_lists",
)
load(
    "@provisioning_exts//shared/otp:common.bzl",
    "otp_c_lib_and_personalized_images",
)

package(default_visibility = ["//visibility:public"])

################################################################################
# CREATOR_SW_CFG
################################################################################
otp_json(
    name = "otp_json_creator_sw_cfg",
    partitions = [
        otp_partition(
            name = "CREATOR_SW_CFG",
            items = {
                # This field is populated by the individualization flow and is
                # not listed directly in this configuration.
                # CREATOR_SW_CFG_AST_CFG = ...
                # Enable AST initialization.
                "CREATOR_SW_CFG_AST_INIT_EN": otp_hex(CONST.MUBI4_TRUE),
                "CREATOR_SW_CFG_ROM_EXT_SKU": otp_hex(0x0),
                # Enable SPX+ signature verification.
                "CREATOR_SW_CFG_SIGVERIFY_SPX_EN": otp_hex(0x0),
                # Enable flash data page scrambling and ECC.
                "CREATOR_SW_CFG_FLASH_DATA_DEFAULT_CFG": otp_hex(0x00090606),
                # Keep scrambling(byte 0), ECC (byte 1), and high-endurance (byte 2) disabled (see https://github.com/lowRISC/opentitan/blob/e0d342218eb796ae1ffd8cba5eedc6fcf9422d87/sw/device/silicon_creator/lib/drivers/flash_ctrl.h#L139-L144, assuming `__CHAR_BIT__` is 8)
                # Each of these fields take [multibit bool 4](https://github.com/lowRISC/opentitan/blob/e0d342218eb796ae1ffd8cba5eedc6fcf9422d87/sw/device/lib/base/multibits.h#L20-L21) as input, with 0x06 corresponding to True and 0x09 corresponding to False
                "CREATOR_SW_CFG_FLASH_INFO_BOOT_DATA_CFG": otp_hex(0x00090909),
                # Keep default scrambling and ECC configuration on keymgr seed
                # flash info pages.
                "CREATOR_SW_CFG_FLASH_HW_INFO_CFG_OVERRIDE": otp_hex(0x0),
                # Disable use of entropy for countermeasures.
                "CREATOR_SW_CFG_RNG_EN": otp_hex(CONST.HARDENED_FALSE),
                # Disable main system clock jitter.
                "CREATOR_SW_CFG_JITTER_EN": otp_hex(CONST.MUBI4_TRUE),
                # Only initialize retention SRAM on PoR.
                "CREATOR_SW_CFG_RET_RAM_RESET_MASK": otp_hex(0x0),
                # ASCII code for post personalization binding: `PERS`.
                "CREATOR_SW_CFG_MANUF_STATE": otp_hex(CONST.MANUF_STATE.PERSONALIZED),
                # Enable ROM execution (any nonzero value works).
                "CREATOR_SW_CFG_ROM_EXEC_EN": otp_hex(0xffffffff),
                # Ibex cpuctrl CSR value written by ROM; 0x1 enables ICACHE.
                "CREATOR_SW_CFG_CPUCTRL": otp_hex(0x1),
                # Default boot data min_security_version_rom_ext: all ROM_EXT
                # firmware versions are valid.
                "CREATOR_SW_CFG_MIN_SEC_VER_ROM_EXT": otp_hex(0x0),
                # Default boot data min_security_version_bl0: all Owner firmware
                # versions are valid.
                "CREATOR_SW_CFG_MIN_SEC_VER_BL0": otp_hex(0x0),
                # Enable the default boot data in PROD/PROD_END LC states.
                "CREATOR_SW_CFG_DEFAULT_BOOT_DATA_IN_PROD_EN": otp_hex(CONST.HARDENED_TRUE),
                # Enable RMA entry ROM busyloop.
                "CREATOR_SW_CFG_RMA_SPIN_EN": otp_hex(CONST.HARDENED_TRUE),
                # Number of clock cycles to spin for when waiting for RMA entry.
                # 0x2000000 == 33,554,432 == ~335ms
                "CREATOR_SW_CFG_RMA_SPIN_CYCLES": otp_hex(0x2000000),
                # Entropy source health check values.
                "CREATOR_SW_CFG_RNG_REPCNT_THRESHOLDS": otp_hex(0xffffffff),
                "CREATOR_SW_CFG_RNG_REPCNTS_THRESHOLDS": otp_hex(0xffffffff),
                "CREATOR_SW_CFG_RNG_ADAPTP_HI_THRESHOLDS": otp_hex(0xffffffff),
                "CREATOR_SW_CFG_RNG_ADAPTP_LO_THRESHOLDS": otp_hex(0x0),
                "CREATOR_SW_CFG_RNG_BUCKET_THRESHOLDS": otp_hex(0xffffffff),
                "CREATOR_SW_CFG_RNG_MARKOV_HI_THRESHOLDS": otp_hex(0xffffffff),
                "CREATOR_SW_CFG_RNG_MARKOV_LO_THRESHOLDS": otp_hex(0x0),
                "CREATOR_SW_CFG_RNG_EXTHT_HI_THRESHOLDS": otp_hex(0xffffffff),
                "CREATOR_SW_CFG_RNG_EXTHT_LO_THRESHOLDS": otp_hex(0x0),
                "CREATOR_SW_CFG_RNG_ALERT_THRESHOLD": otp_hex(0xfffd0002),
                "CREATOR_SW_CFG_RNG_HEALTH_CONFIG_DIGEST": otp_hex(0x8264cf75),
                # Enable SRAM scramble key rotation on every boot.
                "CREATOR_SW_CFG_SRAM_KEY_RENEW_EN": otp_hex(0x0),
                # Disable ROM_EXT immutable section.
                "CREATOR_SW_CFG_IMMUTABLE_ROM_EXT_EN": otp_hex(0x0),
            },
        ),
    ],
)

################################################################################
# OWNER_SW_CFG
################################################################################
otp_json(
    name = "otp_json_owner_sw_cfg",
    partitions = [
        otp_partition(
            name = "OWNER_SW_CFG",
            items = {
                # Report ROM errors without any redaction.
                "OWNER_SW_CFG_ROM_ERROR_REPORTING": otp_hex(CONST.SHUTDOWN.REDACT.NONE),
                # Enable ROM bootstrap.
                "OWNER_SW_CFG_ROM_BOOTSTRAP_DIS": otp_hex(0x0),
                # Disable all alert classes with enables set to kAlertEnableNone.
                "OWNER_SW_CFG_ROM_ALERT_CLASS_EN": otp_per_class_bytes(
                    A = CONST.ALERT.ENABLE,
                    B = CONST.ALERT.ENABLE,
                    C = CONST.ALERT.NONE,
                    D = CONST.ALERT.NONE,
                ),
                # Set all alert escalation policies to kAlertEscalateNone.
                "OWNER_SW_CFG_ROM_ALERT_ESCALATION": otp_per_class_bytes(
                    A = CONST.ALERT.ESC_PHASE_3,
                    B = CONST.ALERT.ESC_PHASE_3,
                    C = CONST.ALERT.ESC_NONE,
                    D = CONST.ALERT.ESC_NONE,
                ),
                # Set all alert classifications to not configured (kAlertClassX).
                "OWNER_SW_CFG_ROM_ALERT_CLASSIFICATION": otp_alert_classification(
                    alert_list = EARLGREY_ALERTS,
                    # Order is:                    prod, prod_end, dev, rma"
                    default = "                               X, X, X, X",
                    ordered_params = {
                        "otp_ctrl_fatal_macro_error": "       A, A, X, X",
                        "otp_ctrl_fatal_check_error": "       A, A, X, X",
                        "otp_ctrl_fatal_bus_integ_error": "   A, A, X, X",
                        "otp_ctrl_fatal_prim_otp_alert": "    A, A, X, X",
                        "lc_ctrl_fatal_state_error": "        A, A, X, X",
                        "lc_ctrl_fatal_bus_integ_error": "    A, A, X, X",
                        "pwrmgr_aon_fatal_fault": "           A, A, X, X",
                        "rstmgr_aon_fatal_fault": "           A, A, X, X",
                        "rstmgr_aon_fatal_cnsty_fault": "     A, A, X, X",
                        "clkmgr_aon_fatal_fault": "           A, A, X, X",
                        "sensor_ctrl_recov_alert": "          B, B, X, X",
                        "sensor_ctrl_fatal_alert": "          A, A, X, X",
                        "sram_ctrl_ret_aon_fatal_error": "    A, A, X, X",
                        "flash_ctrl_fatal_std_err": "         A, A, X, X",
                        "flash_ctrl_fatal_prim_flash_alert": "A, A, X, X",
                        "otbn_fatal": "                       A, A, X, X",
                        "otbn_recov": "                       B, B, X, X",
                        "csrng_recov_alert": "                B, B, X, X",
                        "csrng_fatal_alert": "                A, A, X, X",
                        "entropy_src_recov_alert": "          B, B, X, X",
                        "entropy_src_fatal_alert": "          A, A, X, X",
                        "edn0_recov_alert": "                 B, B, X, X",
                        "edn0_fatal_alert": "                 A, A, X, X",
                        "sram_ctrl_main_fatal_error": "       A, A, X, X",
                        "rom_ctrl_fatal": "                   A, A, X, X",
                        "rv_core_ibex_fatal_sw_err": "        A, A, X, X",
                        "rv_core_ibex_fatal_hw_err": "        A, A, X, X",
                        "rv_core_ibex_recov_hw_err": "        X, X, X, X",
                    },
                ),
                # Set all local alert classifications to not configured (kAlertClassX).
                "OWNER_SW_CFG_ROM_LOCAL_ALERT_CLASSIFICATION": otp_alert_classification(
                    alert_list = EARLGREY_LOC_ALERTS,
                    # Order is:          "prod, prod_end, dev, rma"
                    default = "                      X, X, X, X",
                    ordered_params = {
                        "alert_pingfail": "          A, A, X, X",
                        "esc_pingfail": "            A, A, X, X",
                        "alert_integfail": "         A, A, X, X",
                        "esc_integfail": "           A, A, X, X",
                        "bus_integfail": "           A, A, X, X",
                        "shadow_reg_update_error": " A, A, X, X",
                        "shadow_reg_storage_error": "A, A, X, X",
                    },
                ),
                # Set the alert accumulation thresholds to 0 for each class.
                "OWNER_SW_CFG_ROM_ALERT_ACCUM_THRESH": otp_per_class_ints(
                    A = 3,
                    B = 3,
                    C = 0,
                    D = 0,
                ),
                # Set the alert timeout cycles to 0 per class.
                "OWNER_SW_CFG_ROM_ALERT_TIMEOUT_CYCLES": otp_per_class_ints(
                    A = 0,
                    B = 0,
                    C = 0,
                    D = 0,
                ),
                # Set the alert phase cycles to 0,0xf,0xf,0xa for classes
                # A and B, and to all zeros for classes C and D.
                "OWNER_SW_CFG_ROM_ALERT_PHASE_CYCLES": otp_per_class_lists(
                    A = "0x0, 0xf, 0xf, 0xa",
                    B = "0x0, 0xf, 0xf, 0xa",
                    C = "0x0, 0x0, 0x0, 0x0",
                    D = "0x0, 0x0, 0x0, 0x0",
                ),
                # Set watchdog bite threshold to 200000 cycles.
                "OWNER_SW_CFG_ROM_WATCHDOG_BITE_THRESHOLD_CYCLES": otp_hex(0x30d40),
                # Use the ROM_EXT manifest binding value for first stage
                # attestation binding value.
                "OWNER_SW_CFG_ROM_KEYMGR_OTP_MEAS_EN": otp_hex(0x0),
                # Unused by HW or ROM. SET to `PLAT` for identification.
                "OWNER_SW_CFG_MANUF_STATE": otp_hex(0x54414c50),
                # Set to 0 since ROM expects both reset info sources (alert and
                # cpu crash dump) to be disabled.
                "OWNER_SW_CFG_ROM_RSTMGR_INFO_EN": otp_hex(0x0),
                # Unused. Set to 0.
                "OWNER_SW_CFG_ROM_EXT_BOOTSTRAP_EN": otp_hex(0x0),
                # Enable all AST alerts and configure them as recoverable.
                # In each byte, the lower nybble is a Mubi4 specifying whether
                # to enable the alert and the upper nybble is a Mubi4
                # specifying whether the alert is recoverable.
                "OWNER_SW_CFG_ROM_SENSOR_CTRL_ALERT_CFG": [
                    otp_hex(0x66666666),
                    otp_hex(0x66666666),
                    otp_hex(0x00666666),
                ],
                # Disable SRAM readback for both ret-ram and main sram.
                "OWNER_SW_CFG_ROM_SRAM_READBACK_EN": otp_hex(CONST.MUBI4_TRUE << 4 | CONST.MUBI4_TRUE),
                # Clear the rstmgr reset reason CSR after copying it to retention SRAM.
                "OWNER_SW_CFG_ROM_PRESERVE_RESET_REASON_EN": otp_hex(CONST.HARDENED_FALSE),
                # Skip reset reason validation check in the ROM.
                "OWNER_SW_CFG_ROM_RESET_REASON_CHECK_VALUE": otp_hex(CONST.HARDENED_TRUE << 16 | CONST.HARDENED_TRUE),
                # Enable printing of a banner message in the ROM on every boot.
                "OWNER_SW_CFG_ROM_BANNER_EN": otp_hex(0x0),
                # Enable the flash ECC exception handler in the ROM.
                "OWNER_SW_CFG_ROM_FLASH_ECC_EXC_HANDLER_EN": otp_hex(CONST.HARDENED_TRUE),
            },
        ),
    ],
)

################################################################################
# OWNER_SW_CFG -- alert_handler configuration digests
################################################################################
otp_alert_digest(
    name = "alert_digest_cfg",
    otp_img = ":otp_json_owner_sw_cfg",
)

################################################################################
# C library containing OTP constants to build FT individualization binary and
# personalized OTP images for FPGA testing.
################################################################################
otp_c_lib_and_personalized_images(
    image_seed = "@provisioning_exts//shared/otp/gb00:otp_json_gb00_image_seed",
    sw_overlays = [
        ":otp_json_creator_sw_cfg",
        ":otp_json_owner_sw_cfg",
        ":alert_digest_cfg",
        "@provisioning_exts//open/keys/root:root_keys",
    ],
)

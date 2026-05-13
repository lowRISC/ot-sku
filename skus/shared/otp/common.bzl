# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load(
    "@lowrisc_opentitan//rules:const.bzl",
    "CONST",
    "get_lc_items",
)
load(
    "@lowrisc_opentitan//rules:otp.bzl",
    "otp_image",
    "otp_image_consts",
)

# The `LC_MISSION_STATES` object contains the set of mission mode life cycle
# states.
_LC_MISSION_STATES = get_lc_items(
    CONST.LCV.DEV,
    CONST.LCV.PROD,
    CONST.LCV.PROD_END,
)

def otp_c_lib_and_personalized_images(image_seed, sw_overlays):
    otp_image_consts(
        name = "otp_consts_c_file",
        src = image_seed,
        overlays = sw_overlays,
    )
    native.cc_library(
        name = "otp_consts",
        srcs = [":otp_consts_c_file"],
        deps = [
            "@lowrisc_opentitan//hw/ip/otp_ctrl/data:otp_ctrl_c_regs",
            "@lowrisc_opentitan//sw/device/silicon_creator/manuf/lib:otp_img_types",
        ],
    )

    # Personalized OTP configurations for FPGA testing. Available on
    # `LC_MISSION_STATES` life cycle states.
    # See sw/device/tests/doc/sival/devguide.md for more details.
    [
        otp_image(
            name = "otp_img_{}_manuf_personalized".format(lc_state),
            src = "@lowrisc_opentitan//hw/ip/otp_ctrl/data:otp_json_{}".format(lc_state),
            overlays = [
                "@lowrisc_opentitan//hw/ip/otp_ctrl/data:otp_json_hw_cfg0",
                "@lowrisc_opentitan//hw/ip/otp_ctrl/data:otp_json_hw_cfg1",
                "@lowrisc_opentitan//hw/ip/otp_ctrl/data:otp_json_fixed_secret0",
                "@lowrisc_opentitan//hw/ip/otp_ctrl/data:otp_json_secret1",
                "@lowrisc_opentitan//hw/ip/otp_ctrl/data:otp_json_fixed_secret2",
            ] + sw_overlays,
        )
        for lc_state, _ in _LC_MISSION_STATES
    ]

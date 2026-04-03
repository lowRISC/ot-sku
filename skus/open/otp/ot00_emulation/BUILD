# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# SKU: OT__.
# Version: 00.

load(
    "@provisioning_exts//shared/otp:common.bzl",
    "otp_c_lib_and_personalized_images",
)

package(default_visibility = ["//visibility:public"])

################################################################################
# C library containing OTP constants to build FT individualization binary and
# personalized OTP images for FPGA testing.
################################################################################
otp_c_lib_and_personalized_images(
    image_seed = "@provisioning_exts//shared/otp/gb00:otp_json_gb00_image_seed",
    sw_overlays = [
        "@provisioning_exts//open/otp/ti02:otp_json_creator_sw_cfg",
        "@provisioning_exts//open/otp/ti02:otp_json_owner_sw_cfg",
        "@provisioning_exts//open/otp/ti02:alert_digest_cfg",
        # TODO: replace with your fake keys
        "@lowrisc_opentitan//sw/device/silicon_creator/rom/keys/fake/otp:json_rot_keys",
    ],
)

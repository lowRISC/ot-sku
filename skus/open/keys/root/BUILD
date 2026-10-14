# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:const.bzl", "CONST")
load(
    "@lowrisc_opentitan//rules:otp.bzl",
    "otp_hex",
    "otp_json_rot_keys",
    "otp_partition",
)
load("@lowrisc_opentitan//rules:signing.bzl", "keyset")

package(default_visibility = ["//visibility:public"])

keyset(
    name = "keyset",
    build_setting_default = "",
    keys = {
        "ot00-earlgrey-a2-root-ecdsa-prod-0.pub.der": "ot00-earlgrey-a2-root-ecdsa-prod-0",
        "ot00-earlgrey-a2-root-ecdsa-prod-1.pub.der": "ot00-earlgrey-a2-root-ecdsa-prod-1",
        "ot00-earlgrey-a2-root-ecdsa-prod-2.pub.der": "ot00-earlgrey-a2-root-ecdsa-prod-2",
        "ot00-earlgrey-a2-root-ecdsa-dev-0.pub.der": "ot00-earlgrey-a2-root-ecdsa-dev-0",
    },
    keytype = "ecdsa",
    profile = "earlgrey-a2-open-root",
    tool = "@lowrisc_opentitan//signing:token",
)

keyset(
    name = "spxset",
    build_setting_default = "",
    keys = {
        "ot00-earlgrey-a2-root-slhdsa-prod-0.pub.pem": "ot00-earlgrey-a2-root-slhdsa-prod-0:domain=PreHashedSha256",
        "ot00-earlgrey-a2-root-slhdsa-prod-1.pub.pem": "ot00-earlgrey-a2-root-slhdsa-prod-1:domain=PreHashedSha256",
        "ot00-earlgrey-a2-root-slhdsa-prod-2.pub.pem": "ot00-earlgrey-a2-root-slhdsa-prod-2:domain=PreHashedSha256",
        "ot00-earlgrey-a2-root-slhdsa-dev-0.pub.pem": "ot00-earlgrey-a2-root-slhdsa-dev-0:domain=PreHashedSha256",
    },
    keytype = "slh-dsa",
    profile = "earlgrey-a2-open-root",
    tool = "@lowrisc_opentitan//signing:token",
)

otp_json_rot_keys(
    name = "root_keys",
    partitions = [
        otp_partition(
            name = "ROT_CREATOR_AUTH_CODESIGN",
            items = {
                # ecdsa OTP values created with `opentitantool ecdsa key show <key>`
                # ot00-earlgrey-a2-root-ecdsa-prod-0.pub.der
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY_TYPE0": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY0": "0x1c04eb39d9d19da733256ddc365088f94bf9a94ed1ebdcade3b9f5250a8bd4c88ba433f75649dc67eca767597130355226bbee75debe78bfb9613c5d73fbbf0c",

                # ot00-earlgrey-a2-root-ecdsa-prod-1.pub.der
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY_TYPE1": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY1": "0xf1b2aab7ff1f18a9d43f842b8b840c79ddc1da2de8db26cea6d5cc8f70f81194f14189351cc160ebd147327e4cc01c526693eaf5d890576d4b0f83bd1569d29e",

                # ot00-earlgrey-a2-root-ecdsa-prod-2.pub.der
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY_TYPE2": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY2": "0xf4659f9f9425c19c8bb6ce3c3877936eb211574cd1011700ef8d6c97de142bef483eb38c3c56cd3321f00046a0a1dd58334589ae0010246bebd1dab26d128de0",

                # ot00-earlgrey-a2-root-ecdsa-dev-0.pub.der
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY_TYPE3": otp_hex(CONST.SIGVERIFY.KEY_TYPE.TEST),
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY3": "0x5b42287ff8463b12e686b60279f1c9a8370f01dafb673cc326e64431edbd29844f75b5db48ec5a487e5d9d36a63e62c890d2602ac7ecb9d85c4c9bd016be162e",

                # slhdsa OTP values created with `opentitantool spx key show <key>`
                # ot00-earlgrey-a2-root-slhdsa-prod-0.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_TYPE0": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY0": "0x8a23a0ea1a825290e4bd61f5c3792e5399675a41f68e672eb657167e0fe263ee",
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_CONFIG0": otp_hex(CONST.SPX_CONFIG_ID.SHA2_128S_PREHASH),

                # ot00-earlgrey-a2-root-slhdsa-prod-1.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_TYPE1": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY1": "0x8bb4673c2235ed4a7b2ae48ba50fffec77c651e7bd9a40cffc629ee745498882",
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_CONFIG1": otp_hex(CONST.SPX_CONFIG_ID.SHA2_128S_PREHASH),

                # ot00-earlgrey-a2-root-slhdsa-prod-2.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_TYPE2": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY2": "0x3d803f6fd9daf4b660b279ed08c8c8954f99abe6ba8f936436681830dee816f0",
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_CONFIG2": otp_hex(CONST.SPX_CONFIG_ID.SHA2_128S_PREHASH),

                # ot00-earlgrey-a2-root-slhdsa-dev-0.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_TYPE3": otp_hex(CONST.SIGVERIFY.KEY_TYPE.TEST),
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY3": "0x9577ad5c5d03d7d4860c2b6a2501e7ea5982e0555520c2b0b845a5b3587cb0cf",
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_CONFIG3": otp_hex(CONST.SPX_CONFIG_ID.SHA2_128S_PREHASH),
            },
        ),
        otp_partition(
            name = "ROT_CREATOR_AUTH_STATE",
            items = {
                "ROT_CREATOR_AUTH_STATE_ECDSA_KEY0": otp_hex(CONST.SIGVERIFY.KEY_STATE.PROVISIONED),
                "ROT_CREATOR_AUTH_STATE_ECDSA_KEY1": otp_hex(CONST.SIGVERIFY.KEY_STATE.PROVISIONED),
                "ROT_CREATOR_AUTH_STATE_ECDSA_KEY2": otp_hex(CONST.SIGVERIFY.KEY_STATE.PROVISIONED),
                "ROT_CREATOR_AUTH_STATE_ECDSA_KEY3": otp_hex(CONST.SIGVERIFY.KEY_STATE.PROVISIONED),
                "ROT_CREATOR_AUTH_STATE_SPX_KEY0": otp_hex(CONST.SIGVERIFY.KEY_STATE.PROVISIONED),
                "ROT_CREATOR_AUTH_STATE_SPX_KEY1": otp_hex(CONST.SIGVERIFY.KEY_STATE.PROVISIONED),
                "ROT_CREATOR_AUTH_STATE_SPX_KEY2": otp_hex(CONST.SIGVERIFY.KEY_STATE.PROVISIONED),
                "ROT_CREATOR_AUTH_STATE_SPX_KEY3": otp_hex(CONST.SIGVERIFY.KEY_STATE.PROVISIONED),
            },
        ),
    ],
)

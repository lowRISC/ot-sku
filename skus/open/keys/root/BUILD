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
    profile = "earlgrey-a2-open-root",
    tool = "@lowrisc_opentitan//signing:token",
)

# TODO: add key material in OTP representation.
# TODO: I think the `TEST` keys should be `DEV`.
otp_json_rot_keys(
    name = "root_keys",
    partitions = [
        otp_partition(
            name = "ROT_CREATOR_AUTH_CODESIGN",
            items = {
                # ecdsa OTP values created with `opentitantool ecdsa key show <key>`
                # ot00-earlgrey-a2-root-ecdsa-prod-0.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY_TYPE0": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY0": "0x449b283f7d6d6e0d421443b0d3856e4e3d0b6996d6b3130793a3208f867e0bfd2da0093b1629eec5f2bba75f5c6c7aa573b436ccc4df5e6505b0a43f920b4047",

                # ot00-earlgrey-a2-root-ecdsa-prod-1.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY_TYPE1": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY1": "0x6edd3cb1162333c7ea35adbd57669486f68929c27e062cc19fecbbad06445278ed56b87d5e774a6c62eeff5a62ff04f653cac5b45024befeea9073f37a9529cf",

                # ot00-earlgrey-a2-root-ecdsa-prod-2.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY_TYPE2": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY2": "0x65b31f407cacfcdea2a96bc7dd545c596292d1245524214112bd21bf31e9fb733258988ef8f3db0afe59a3b7355eaf33a8a8e91586d200c2995fcd9a859aa475",

                # ot00-earlgrey-a2-root-ecdsa-dev-0.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY_TYPE3": otp_hex(CONST.SIGVERIFY.KEY_TYPE.TEST),
                "ROT_CREATOR_AUTH_CODESIGN_ECDSA_KEY3": "0xd824d4a5239c3053aed648ba5d8f77a32b4f423fa6452989a617af7c3575e9e6b2bb1e82b15793abef71bfc10a1d2d4f327063d60a549dd69c0d7a3604f91da5",

                # slhdsa OTP values created with `opentitantool spx key show <key>`
                # ot00-earlgrey-a2-root-slhdsa-prod-0.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_TYPE0": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY0": "0x5343018c9c679feb5b6c1b9a11a408a2817780835f7dfb6e902bb3f2623ddf94",
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_CONFIG0": otp_hex(CONST.SPX_CONFIG_ID.SHA2_128S_PREHASH),

                # ot00-earlgrey-a2-root-slhdsa-prod-1.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_TYPE1": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY1": "0x3a3db784138bf45e6411d31cb9aaf235f16746dbfdace0425319375b9a92fe25",
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_CONFIG1": otp_hex(CONST.SPX_CONFIG_ID.SHA2_128S_PREHASH),

                # ot00-earlgrey-a2-root-slhdsa-prod-2.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_TYPE2": otp_hex(CONST.SIGVERIFY.KEY_TYPE.PROD),
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY2": "0x31989d4779936c6bfb0d280160426d7eeb28330a00f8ccbaf9a53a957f5b43d5",
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_CONFIG2": otp_hex(CONST.SPX_CONFIG_ID.SHA2_128S_PREHASH),

                # ot00-earlgrey-a2-root-slhdsa-dev-0.pub.pem
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY_TYPE3": otp_hex(CONST.SIGVERIFY.KEY_TYPE.TEST),
                "ROT_CREATOR_AUTH_CODESIGN_SPX_KEY3": "0x16e81526e12922bfbbe36754bc111b4e34a5a1bbb5bdaf34c385d368333aa977",
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

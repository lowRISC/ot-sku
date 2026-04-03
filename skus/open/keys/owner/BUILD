# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:signing.bzl", "keyset")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all_keys",
    srcs = glob([
        "*.der",
        "*.pem",
    ]),
)

keyset(
    name = "keyset",
    build_setting_default = "",
    keys = {
        "nuvoton-ot00-app-ecdsa-prod-0.pub.der": "nuvoton-ot00-app-ecdsa-prod-0",
        "nuvoton-ot00-app-ecdsa-prod-1.pub.der": "nuvoton-ot00-app-ecdsa-prod-1",
        "nuvoton-ot00-app-ecdsa-dev-0.pub.der": "nuvoton-ot00-app-ecdsa-dev-0",
    },
    profile = "nuvoton-ot00-app",
    tool = "@lowrisc_opentitan//signing:token",
)

keyset(
    name = "spxset",
    build_setting_default = "",
    keys = {
        "nuvoton-ot00-app-slhdsa-prod-0.pub.pem": "nuvoton-ot00-app-slhdsa-prod-0",
        "nuvoton-ot00-app-slhdsa-prod-1.pub.pem": "nuvoton-ot00-app-slhdsa-prod-1",
        "nuvoton-ot00-app-slhdsa-dev-0.pub.pem": "nuvoton-ot00-app-slhdsa-dev-0",
    },
    profile = "nuvoton-ot00-app",
    tool = "@lowrisc_opentitan//signing:token",
)

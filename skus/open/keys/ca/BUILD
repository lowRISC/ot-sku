# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:signing.bzl", "keyset")

package(default_visibility = ["//visibility:public"])

exports_files(glob(["**"]))

filegroup(
    name = "ca_data",
    srcs = [
        # The fake RMA unlock token wrapping key is used for FPGA testing.
        "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/fake:rma_unlock_enc_rsa3072.pub.der",
        # The sival RMA unlock token wrapping key is shared amongst SKUs for sample chips only.
        "@lowrisc_opentitan//sw/device/silicon_creator/manuf/keys/sival:rma_unlock_enc_rsa3072.pub.der",
        "@provisioning_exts//open/keys/ca:dice_ca.pem",
    ],
)

keyset(
    name = "endorsement",
    build_setting_default = "",
    keys = {
        "nuvoton-ot00-ca-ecdsa-0.pub.der": "nuvoton-ot00-ca-ecdsa-0",
    },
    profile = "nuvoton-ot00-ca",
    tool = "@lowrisc_opentitan//signing:token",
)

# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@lowrisc_opentitan//rules:sku.bzl", "sku_cert", "sku_cfg")
load("//:cfg.bzl", "STANDARD_SKUS")
load("//open/orchestrator:defs.bzl", "standard_sku_cfg")

package(default_visibility = ["//visibility:public"])

# TODO: Update to real OT01 CA certificate and key after keygen.
sku_cert(
    name = "ot01_dice_ca",
    certificate = "//open/keys/ca:dice_ca.pem",
    key = "nuvoton-ot00-ca-ecdsa-0",
    key_id = "0x7CDDE6D1C7C7B3A87233A3EF92FD2159A09308DC",
    key_type = "Token",
)

# Automatically define configurations for standard SKUs.
[
    standard_sku_cfg(
        name = sku,
        cfg = cfg,
    )
    for (sku, cfg) in STANDARD_SKUS.items()
]

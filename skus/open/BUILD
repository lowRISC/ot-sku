# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@rules_rust//rust:defs.bzl", "rust_library")

package(default_visibility = ["//visibility:public"])

# Benchtop provisioning orchestrator configuration file.
exports_files([
    "emulation_gb_ti.hjson",
    "gb_ti.hjson",
])

cc_library(
    name = "personalize_fw_ext",
    srcs = ["personalize_ext.c"],
    deps = [
        "@lowrisc_opentitan//sw/device/silicon_creator/manuf/base:personalize_ext",
    ],
)

rust_library(
    name = "ft_ext_lib",
    srcs = ["ft_ext_lib.rs"],
    deps = [
        "@crate_index//:anyhow",
        "@crate_index//:arrayvec",
        "@crate_index//:log",
        "@lowrisc_opentitan//sw/host/provisioning/util_lib",
    ],
)

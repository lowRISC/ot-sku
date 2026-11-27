# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# This Build file allows resolution for a given SKU to find out all of the
# keys in corresponding keysets for the SKU.  This ultimately makes
# it possible to establish where keys need to be exported for this SKU.
#
# Example of how to use this (from your OT repo root):
# bazelisk.sh --override_module=ot_provisioning_exts=<ot-sku-root> \
#   cquery \
#   --@provisioning_exts//open/fake_keygen/scripts:ot_sku="emulation_open" \
#   @provisioning_exts//open/fake_keygen/scripts:keyfile_targets \
#   --output="files"
#

load("@provisioning_exts//:cfg.bzl", "EXT_EARLGREY_SKUS")
load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

package(default_visibility = ["//visibility:public"])

# Flag to pass the SKU from 
# Reasonable to assume EXT_EARLGREY_SKUS contains at least one entry.
string_flag(
    name = "ot_sku",
    build_setting_default = EXT_EARLGREY_SKUS.keys()[0],
    values = EXT_EARLGREY_SKUS.keys()
)

# List comprehension as we are in a BUILD file so no for loops...
[config_setting(
        name = "sku_{}".format(sku),
        flag_values = {":ot_sku": sku}
  ) for sku in EXT_EARLGREY_SKUS
]


# We need the file targets for keys defined for the SKU passed in the flag
# The keysets available are ecdsa_key and spx_key - see EXT_EARLGREY_SKUS.
filegroup(
    name = "keyfile_targets",
    srcs = select({
        ":sku_{}".format(sku):
            EXT_EARLGREY_SKUS[sku]["ecdsa_key"].keys()
            + EXT_EARLGREY_SKUS[sku]["spx_key"].keys()
        for sku in EXT_EARLGREY_SKUS
    }),
)

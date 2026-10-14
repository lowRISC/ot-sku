# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "ecdsa_signatures",
    srcs = glob(
        ["*.ecdsa_sig"],
        allow_empty = True,
    ),
)

filegroup(
    name = "spx_signatures",
    # SPHINCS+ & SLH-DSA signatures are consumed via the `spx_signatures` target by
    # upstream OpenTitan signing rules. This SKU uses SLH-DSA keys.
    srcs = glob(
        ["*.slh_dsa_sig"],
        allow_empty = True,
    ),
)

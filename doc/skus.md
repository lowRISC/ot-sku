<!--
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
-->

# SKUs

[`skus/cfg.bzl`](../skus/cfg.bzl) and [`skus/open/orchestrator/BUILD`](../skus/open/orchestrator/BUILD) collectively define three different SKUs:
1. `ot00` is the zeroth iteration of the Open Market SKU.
   Binaries are signed offline and integrated via a GitHub Release flow (see [`create_release.md`](./create_release.md)), which they are then sourced from.
   The DICE CA key for endorsing the Unique Device Secret (UDS) is private - known only to the manufacturer - and so this SKU cannot be tested in online FPGA flows.
2. `ot00_staging` is a staging variant of the Open Market SKU.
   It is the exact same as `ot00`, except that it can be used in online FPGA flows, as it uses OpenTitan's `emulation_dice_ca`, using a fake CA key that is checked into upstream OpenTitan for UDS endorsement.
   This allows for the full manufacturing flow to be tested on an FPGA, using the same signed binaries that are sourced from GitHub Releases via an offline signing ceremony.
3. `emulation_open` is an Emulation SKU.
   Its intention is to use the same OTP configuration as the real open-market SKU (except for the root keys), instead making use of the fake signing keys defined in `opentitan` so that it can be easily used to test signing flows without requiring any offline step.

In summary: `ot00` defines the Open Market SKU. The staging variant allows full FPGA testing of signed artifacts via use of a fake endorsement key & cert, and the emulation variant uses only fake `opentitan` keys to run the full flow online without a manual offline signing step.

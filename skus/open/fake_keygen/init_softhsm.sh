#!/bin/bash
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set -eou pipefail

# Change directory to the repository root
cd $(dirname $0)
cd $(git rev-parse --show-toplevel)

source skus/open/keygen/softhsm_sourceme.sh

softhsm2-util --init-token --label temp --so-pin officer_pin --pin 123456 --free

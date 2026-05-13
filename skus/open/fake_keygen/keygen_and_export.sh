#!/bin/bash
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set -eou pipefail

: ${HSMTOOL?Error: set HSMTOOL to the location of hsmtool from earlgrey_1.0.0}
: ${TOKEN:=temp}
: ${PIN:=123456}

DIR=$(dirname $0)

function keygen_and_export {
  local dir=$1

  cd ${dir}
  ${HSMTOOL} -t ${TOKEN} -u user -p ${PIN} exec keygen.json5
  ${HSMTOOL} -t ${TOKEN} -u user -p ${PIN} exec export.json5
  ${HSMTOOL} -t ${TOKEN} -u user -p ${PIN} exec export_public.json5

  tar -zcf ${dir}-private.tar.gz *.pem *.der
  tar -zcf ${dir}-public.tar.gz *.pub.pem *.pub.der
  cd ..
}

# Change directory to the repository root
cd $(dirname $0)
cd $(git rev-parse --show-toplevel)
source skus/open/fake_keygen/softhsm_sourceme.sh

# Now change to the keygen subdir and generate keys
cd skus/open/fake_keygen
#keygen_and_export root
#keygen_and_export owner
#keygen_and_export application
keygen_and_export ca

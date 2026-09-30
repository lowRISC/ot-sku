# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Env vars setup for SoftHSM and hsmtool

if [[ -e skus/open/fake_keygen/softhsm2.conf ]]; then

  export SOFTHSM2_CONF=${PWD}/skus/open/fake_keygen/softhsm2.conf
  export HSMTOOL_MODULE=/usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so

  # If we want to use any SPHINCS+ keys (distinct from SLH-DSA keys), we must set the
  # SPX_MODULE to be used. Note that for any SPHINCS+ keys that are stored in the token,
  # PKCS#11 elementary files (CKO_DATA objects) are used to store the key material.
  export HSMTOOL_SPX_MODULE=pkcs11-ef

  # Default configuration for the checked-in database (used for **testing only**)
  export HSMTOOL_TOKEN=temp
  export HSMTOOL_USER=user
  export HSMTOOL_PIN=123456

  cat >${SOFTHSM2_CONF} <<EOT
# SoftHSM v2 configuration file

## Note: this is relative to the root of this repo.
directories.tokendir = ${PWD}/skus/open/fake_keygen/data
objectstore.backend = file

# ERROR, WARNING, INFO, DEBUG
log.level = WARNING

# If CKF_REMOVABLE_DEVICE flag should be set
slots.removable = false

# Enable and disable PKCS#11 mechanisms using slots.mechanisms.
slots.mechanisms = ALL

# If the library should reset the state on fork
library.reset_on_fork = true
EOT

else
  echo "Expected CWD to be the root of the ot-sku repository."
fi

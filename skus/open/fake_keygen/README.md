<!--
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
-->

# Open Market SKU Keygen Templates

This subdirectory contains `hsmtool` templates for generating the key material
for the Open Market SKU and a simple SoftHSM2 configuration for practicing the
keygen process.

There are 3 classes of keys to be generated:
- root keys
- owner keys
- application keys

In each of the subdirs `root`, `owner` and `application`, there are hsmtool JSON
templates to perform keygen and export.  The templates are simply the JSON form
of the command-line arguments that you'd use to perform a given operation.

The following templates are included in each of the subdirs:

- `keygen.json5`: Generate ECDSA and SLHDSA keys.
- `export.json5`: Export the private key material.
- `export_public.json5`: Export the public key material.

The exported ECDSA key material is in DER format and the exported SLH-DSA key material is in PEM format.
Both contain the standard PKCS#8 (/ SPKI) key objects.

## Practicing with SoftHSM2

You can perform a practice run of keygen and export using SoftHSM2.

1. Update `softhsm_sourceme.sh` and adjust the path of `SOFTHSM2_CONF`.
   If you're using a patched SoftHSM (e.g. from OpenTitan), you may also need to ensure the `HSMTOOL_MODULE` points to the right patched `libsofthsm2.so`.
   Then source this file to set up your environment.
2. Ensure that the generated `softhsm2.conf` contains a `directories.tokendir` path to
   the correct token path (`skus/open/fake_keygen/data` in this repository).
3. Remove any previous token storage, if present (e.g. `rm -rf <uuid-like-name>`)
4. Initialize the token: `./init_softhsm.sh`.
5. Generate and export everything: `./keygen_and_export.sh`.

Once the script completes, you can examine the files left in each of the `root`,
`owner` and `application` subdirs.

- There will be a collection of `.pem` and `.pub.pem` files holding private and
  public keys (respectively).
- There will be a pair of TAR archives with the private and public key material.

See more relevant documentation about then propagating the key changes into the SKU in [`doc/key_management.md`](../../../doc/key_management.md).

### Rotating & re-generating keys

Since the default key generation templates define `CKA_DESTROYABLE: false`, you cannot simply destroy a key and re-use its label.
To rotate keys, one option would be to manually modify the key generation files to make the labels unique (for example by adding an `-id` suffix denoting the generation).
For SoftHSM, it is recommended to:

1. Remove the old token: `rm -rf skus/open/fake_keygen/data/*`.
2. Initialize a fresh token, as above: `./init_softhsm.sh`.
3. Generate and export everything, as above: `./keygen_and_export.sh`

## TODOs

1. Learn how to execute the templates on a real HSM rather than SoftHSM (for
   example, the Entrust HSMs often require you to set some magic environment
   variables if you want to generate keys that can be exported, such as
   `CKNFAST_OVERRIDE_SECURITY_ASSURANCES=tokenkeys`).

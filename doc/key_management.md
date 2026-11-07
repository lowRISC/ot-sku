<!--
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
-->

# Key management and Signing

## Manufacturing

This brief prelude provides a quick overview of the different stages involved in OpenTitan's provisioning flow:

 * The unsigned **CP (Chip Probe)** provisioning image is run on the wafer from SRAM, populating a wafer authentication secret in flash and test unlock/exit tokens in OTP -- this step does not tend to vary by SKU.
   The unique CP device ID is then read back from the chip
 * Next comes the **FT (Final Test)** provisioning, which occurs on the packaged chips.
   * The first stage of FT is called **Individualization**, which again runs unsigned from SRAM.
     This configures the FT device ID, creator & owner SW config, public keys for authentication and default boot data in OTP.
     It performs the per-SKU OTP configuration, but does *not* use signed binaries.
   * The last stage of FT is called **Personalization**, which loads *signed* binaries into flash, which are then executed by ROM.
     This stage provisions the OTP `SECRET1` and `SECRET2` partitions, and stores Key Manager & DICE seeds in flash info pages, setting up the device's identity.
     It generates certificate bodies (the `UDS` certificate, and optionally TPM certs) which it then sends to the host, endorsing them with the CA key.
     The device then writes the signed certificates into flash.
     This stage also sets the first owner, installing the owner config & keyring, and erasing relevant owner info.
     For efficiency, this whole stage split into two steps, each of which has its own signed binary:
     * **Flash scrambling** provisions just `SECRET1` and the flash data scrambling config, and is a cut-down loader without extra prints.
     * **Personalize** performs the rest of the flow, as described above.

## Artifacts

There are two types of artifacts that we are interested in signing:

1. **Personalization binaries** (also called "perso" for short).
   These are the flash scrambling and personalization binaries described above that are used in manufacturing at the end of the FT (Final Test) stage.
   These might also include extension hooks defined for the SKU.
2. **ROM_EXT**.
   This is the ROM extension that the ROM will boot into after the chip has been provisioned, which will then (try to) boot into `BL0`, the first stage boot.

## Keys

Four classes of key material are defined for the Open Market SKU:

1. **Root keys**, i.e. the Silicon Creator keys.
   These populate the OTP's `ROT_CREATOR_AUTH_CODESIGN` partition and are used to sign ROM_EXT and personalization binaries.
2. **Owner keys**.
   These are verified by the ROM_EXT, and form part of the "owner block".
   They are used to:
   1. Sign the owner configuration block itself.
   2. For ownership transfer: to authorize "unlocking" ownership, so the chip can be handed over, and to authorize activating a new owner configuration after a transfer.
3. **Application keys**.
   These will live in the owner block's application keyring, and are used to sign the owner's firmware (i.e. `BL0` and anything that comes after it).
   These are hence verified by the ROM_EXT when it tries to boot into BL0.
4. **DICE CA keys**.
   These are used to sign each chip's UDS certificate (and optionally the TPM certs via the ext CA) off-device during personalization.
   This is then verified by anybody who wants to check the full DICE attestation chain of the device.

Root, owner and application keys are defined for ECDSA P-256 and SLH-DSA-SHA2-128s signing.
DICE CA keys only use ECDSA P-256.
For root keys, there are 4 separate slots in the OTP `ROT_CREATOR_AUTH_CODESIGN` partition.

### Key Roles

Keys can be of the `PROD`, `DEV` or `TEST` roles, which restrict the life-cycle states that those keys are valid in.
`PROD` keys are can be used across all modes, `DEV` keys can be used in all non-prod LC states, whereas `TEST` keys can only be used in the `TEST_UNLOCKED` and `RMA` LC states.

For emulation with fake keys, it is typical to assign 1 `TEST` key, 1 `DEV` key and 2 `PROD` keys.
For configuration of real SKUs, it is typical to assign 3 mission-mode (i.e. `PROD` or `DEV`) keys to the first 3 slots, and a test key to the 4th slot.
To change the type of a given key, the `ROT_CREATOR_AUTH_CODESIGN_*_KEY_TYPE*` values in the OTP can be updated.

## Key Generation

For real releases, keys should be generated and maintained in a Hardware Security Module (HSM) in a secure, offline environment.
<!-- TODO: does it make sense to have the real keygen templates stored under a `fake_keygen` sub-directory? -->
<!-- TODO: for fake keygen of root keys, why do we create a key named `dev` but use it as a test key? Is this misnamed? -->
Key generation & export templates can be found in `skus/open/fake_keygen/*/*.json5` files, which can be used with `hsmtool` to generate keys.
You should check that the configuration in these key generation templates matches what you expect -- for example, many private keys are made extractable to allow importing into another HSM, which may or may not be desired.

For testing the Open Market SKU release flow that is defined in this repository, you can use a local SoftHSM2 instance populated with fake keys.
See the documentation in [`skus/open/fake_keygen`](../skus/open/fake_keygen/README.md) for more information.
This documentation assumes that you have set up your environment as appropriate for your HSM; the below instructions all set up the test SoftHSM2 environment *as an example*.

<!-- TODO: how should real HSMs handle key rotation? The current key-generation does not support e.g. ID suffixes -->

## Propagating new keys into the SKU

After *any* key generation (fake *or* real), the following manual steps are required to update the Open Market SKU.
Note that after following these steps, the OTP image is changed and therefore binaries signed with old keys will stop booting.

1. **Copy the public keys into the Open SKU sub-directories**

```sh
tar -xzf skus/open/fake_keygen/root/root-public.tar.gz               -C skus/open/keys/root
tar -xzf skus/open/fake_keygen/owner/owner-public.tar.gz             -C skus/open/keys/owner
tar -xzf skus/open/fake_keygen/application/application-public.tar.gz -C skus/open/keys/owner
tar -xzf skus/open/fake_keygen/ca/ca-public.tar.gz                   -C skus/open/keys/ca
```

The keysets defined in the `BUILD` files reference these keys directly by name, and so no change is needed unless the names of these keys were changed.

2. **Update the root key OTP values in the `ROT_CREATOR_AUTH_CODESIGN` partition**

This is a manual step, since `skus/open/keys/root:root_keys` embeds the root public key material into the OTP, for ROM_EXT / perso validation.
Due to the intricacies in the tooling for generating OTP images, and the format the key material is represented in, it is recommended to use `opentitantool` to recompute these key values:

```sh
# This only covers ECDSA and SLH-DSA keys, since these are the only defined keysets at the time of writing.
for k in skus/open/keys/root/*-ecdsa-*.pub.der; do echo "$k"; opentitantool ecdsa key show "$k"; done
for k in skus/open/keys/root/*-slhdsa-*.pub.pem; do echo "$k"; opentitantool spx key show "$k"; done
```
Take the values in the `otp_encoded` fields and modify the `ROT_CREATOR_AUTH_CODESIGN_*_KEY*` items of `skus/open/keys/root:root_keys` accordingly.
Make sure that the correct public key material is placed into the correct key slot.

3. **Regenerate the X.509 Dice CA self-certificate**

This step is only required if you have rotated/generated a CA key.
This step will require you to have `openssl` available with a defined PKCS11 module.
Note that the below configuration defines a certificate that is valid for centuries, with the standard configuration defined in [`skus/open/keys/ca/dice_ca.conf`](../skus/open/keys/ca/dice_ca.conf).
<!-- TODO: the upstream UDS template at `sw/device/silicon_creator/lib/cert/uds.hjson` hard-codes the issuer as Google.
Check (and potentially fix) how this is handled so that the CA subject can be changed if desired? -->

```sh
# Configure the environment your PKCS11 module, this just uses SoftHSM2 as an example.
source skus/open/fake_keygen/softhsm_sourceme.sh
export PKCS11_MODULE_PATH=${HSMTOOL_MODULE}

# Generate the Dice CA self-certificate
openssl req -new -x509 \
  -config skus/open/keys/ca/dice_ca.conf \
  -engine pkcs11 -keyform engine \
  -key "pkcs11:token=temp;object=nuvoton-ot00-ca-ecdsa-0;type=private?pin-value=123456" \
  -sha256 -days 99999 \
  -out skus/open/keys/ca/dice_ca.pem
```

At this step, it's worth doing some sanity checks to verify the generated certificate:
```sh
# Verify the cert against itself as the trusted CA, to check it is a valid self-signed root cert.
openssl verify -CAfile skus/open/keys/ca/dice_ca.pem skus/open/keys/ca/dice_ca.pem

# Extract the public key from the X.509 cert, and check it matches the actual public key.
openssl x509 -in skus/open/keys/ca/dice_ca.pem -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | cmp - skus/open/keys/ca/nuvoton-ot00-ca-ecdsa-0.pub.der && echo "key matches"
```

4. **Update the CA key ID in the orchestrator config**

This step is only required if you have rotated/generated a CA key.
OpenSSL with a defined PKCS11 module is again required for this step.

```sh
# Configure the environment your PKCS11 module, this just uses SoftHSM2 as an example.
source skus/open/fake_keygen/softhsm_sourceme.sh
export PKCS11_MODULE_PATH=${HSMTOOL_MODULE}

# Generate the CA `subjectKeyIdentifier` for configuring the provisioning orchestrator.
# OpenSSL outputs colon-separated bytes in hex, so we do some post-processing.
openssl x509 -in skus/open/keys/ca/dice_ca.pem -noout -ext subjectKeyIdentifier \
  | tail -1 | tr -d ' :' | sed 's/^/0x/'

# Provided that `dice_ca.conf` still uses `subjectKeyIdentifier = hash`, you can verify
# this by cross-checking against the exported public key.
tail -c 65 skus/open/keys/ca/nuvoton-ot00-ca-ecdsa-0.pub.der \
  | sha1sum | awk '{print "0x" toupper($1)}'
```

Copy the output value into the `sku_cert` struct under `skus/open/orchestrator/BUILD` (e.g. `ot00_dice_ca`), replacing the `key_id` with the output value.

5. **Verify key names**

This step is only required if you have changed the names of any keys (or added/removed them).
The owner block configuration in `skus/open/rom_ext/owner.json5`, which references the owner & application keys by path.
If you have changed the key names, you will also want to edit this file.
In the owner block, you can also choose which owner / application keys are used for signing (e.g. to use ECDSA-only or a Hybrid ECDSA/SLH-DSA scheme).

6. **Perform a release**.

At this stage, you can follow the GitHub release flow as documented in [`create_release.md`](./create_release.md), which requires performing a **signing ceremony** (as documented in [`signing_ceremonies.md`](./signing_ceremonies.md)) to make a release.
The final post-release flow will add commits to the release branch that updates the archives pinned in `extension.bzl` to point to the new release binaries.
A PR can then be made from the release branch to use the release binaries, which will then match the rotated keys.

7. **Verification**.

Check that the signed releases binaries work as intended, for example by testing the following commands:

```sh
# From your OpenTitan checkout (replace the below path to `ot-sku`):
export BAZEL_OVERRIDE_ARGS=--override_module=ot_provisioning_exts=/path/to/ot-sku

# Build the OTP constants & owner configuration:
bazelisk build ${BAZEL_OVERRIDE_ARGS} @provisioning_exts//open/otp/ot00:otp_consts
bazelisk build ${BAZEL_OVERRIDE_ARGS} @provisioning_exts//open/rom_ext:owner_config_bin

# Test the signatures on the signed binaries:
bazelisk test ${BAZEL_OVERRIDE_ARGS} --test_output=streamed \
  @provisioning_exts//open/binaries/perso:signature_test \
  @provisioning_exts//open/binaries/rom_ext:signature_test

# Test the multi-stage end-to-end orchestrator test on FPGA. This will run the full
# provisioning flow, in multiple stages (CP only, then FT only), and boot into
# the ROM_EXT. With a CW310 available:
bazelisk test ${BAZEL_OVERRIDE_ARGS} --test_output=streamed \
  //sw/host/provisioning/orchestrator/tests:e2e_multistage_ot00_staging_hyper310_test

# Or with a CW340 available:
bazelisk test ${BAZEL_OVERRIDE_ARGS} --test_output=streamed \
  //sw/host/provisioning/orchestrator/tests:e2e_multistage_ot00_staging_cw340_test
```

## Recovery Plan

TODO: document the disaster recovery plan (how are back-ups / restores of key material handled. Are PROD keys made extractable from the HSM?)
Key wrapping for backups so plain-text private key material never leaves the HSM.

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

NOTE: Due to a quirk of hsmtool's SLHDSA support, the SLHDSA private material is
exported in the generate stage.

The exported key material is in PEM format.

- For ECDSA keys, the PEM container holds a PKCS#8 key object.
- For SLHDSA keys, the PEM contains holds the raw key material (this is because
  SLHDSA support was developed before there was a standard container object).

## Practicing with SoftHSM2

You can perform a practice run of keygen and export using SoftHSM2.

1. Update `softhsm_sourceme.sh` and adjust the path of `SOFTHSM2_CONF`.
2. Update `softhsm.conf` and adjust the token path.
3. Remove any previous token storage, if present (e.g. `rm -rf <uuid-like-name>`)
4. Initialize the token: `./init_softhsm.sh`.
5. Generate and export everything: `./keygen_and_export.sh`.

Once the script completes, you can examine the files left in each of the `root`,
`owner` and `application` subdirs.

- There will be a collection of `.pem` and `.pub.pem` files holding private and
  public keys (respectively).
- There will be a pair of TAR archives with the private and public key material.

## TODOs

1. Update upstream `hsmtool` to support SLH-DSA via PKCS#11.
2. Update the local templates to use SLH-DSA for PKCS#11.
3. Learn how to execute the templates on a real HSM rather than SoftHSM (for
   example, the Entrust HSMs often require you to set some magic environment
   variables if you want to generate keys that can be exported, such as
   `CKNFAST_OVERRIDE_SECURITY_ASSURANCES=tokenkeys`).

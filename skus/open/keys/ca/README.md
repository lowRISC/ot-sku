# DICE CA key and certificate

This subdirectory contains the ECDSA public CA key and a self signed
certificate.  The private key is located in the `fake_keygen` SoftHSM2 instance
in this repository.

The certificate was created and self-signed by using the `openssl` tool:

```sh
# You may need to adjust the module path.
export PKCS11_MODULE_PATH=/usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so

openssl req -new -x509 \
    -config skus/open/keys/ca/dice_ca.conf \
    -engine pkcs11 \
    -keyform engine \
    -key "pkcs11:object=nuvoton-ot00-ca-ecdsa-0" \
    -sha256 \
    -days 99999 \
    -out skus/open/keys/ca/dice_ca.pem
```

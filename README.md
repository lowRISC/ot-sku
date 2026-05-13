# ot-sku

This repository defines the configuration for the OpenTitan Earlgrey Open-Market
SKU. This repository is meant to be linked into the upstream opentitan
repository (branch `earlgrey_1.0.0`) by the `PROV_EXTS_DIR` environment variable.

The file `skus/cfg.bzl` contains the toplevel configuration data for this
repository.  The opentitan repository will use this configuration to configure
the provisioning firmware and test targets for the SKUs in `cfg.bzl`.

### Example
```sh
git clone https://github.com/lowRISC/opentitan
git clone https://github.com/lowRISC/ot-sku

export PROV_EXTS_DIR=${PWD}/ot-sku/skus

cd opentitan

# Now you can perform your builds or tests
bazel test --test_output=streamed //sw/host/provisioning/orchestrator/tests:e2e_multistage_ot00_staging_hyper310_test

bazel build @provisioning_exts//open/rom_ext:rom_ext_dice_x509_prod_slot_virtual
```

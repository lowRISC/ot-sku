<!--
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
-->

# ot-sku

## About this repository

This repository defines the configuration for the OpenTitan Earlgrey Open-Market SKU.
This repository is meant to be linked into the upstream `opentitan` repository (the [`earlgrey_1.0.0`](https://github.com/lowRISC/opentitan/tree/earlgrey_1.0.0) branch) by the `PROV_EXTS_DIR` environment variable.

The file `skus/cfg.bzl` contains the top-level configuration data for this repository.
The `opentitan` repository will use this configuration to configure the provisioning firmware and test targets for the SKUs defined in `cfg.bzl`.

OpenTitan is administered by [lowRISC CIC](https://www.lowrisc.org) as a collaborative project to produce high quality, open IP for instantiation as a full-featured product.
See the [OpenTitan site](https://opentitan.org) and [OpenTitan docs](https://opentitan.org/book/) for more information about the project.

## Getting Started

The main usage of this repository will come through automated Github workflows - as such, it is not anticipated that much local development will be necessary.
If this *is* needed, most required tooling is packaged by [Bazel](https://bazel.build/).
The recommended development flow is to install [Bazelisk](https://github.com/bazelbuild/bazelisk), which will automatically manage bazel versions for you.

Since this repository hooks into OpenTitan, you may need to install many of the dependencies that are required by OpenTitan if you want to manually run the automated flows.
See OpenTitan's "[Getting started](https://opentitan.org/book/doc/getting_started/index.html)" documentation for more information.


### Example

```sh
git clone https://github.com/lowRISC/opentitan
git clone https://github.com/lowRISC/ot-sku

export PROV_EXTS_DIR=${PWD}/ot-sku/skus

cd opentitan
git fetch origin earlgrey_1.0.0
git checkout earlgrey_1.0.0

# Now you can perform your builds or tests
bazelisk test --test_output=streamed //sw/host/provisioning/orchestrator/tests:e2e_multistage_ot00_staging_hyper310_test

bazelisk build @provisioning_exts//open/rom_ext:rom_ext_dice_x509_prod_slot_virtual
```

## Creating Releases

GitHub [releases](https://github.com/lowRISC/ot-sku/releases) are used to automate the majority of the signing flows.
For more detailed documentation covering how to create a release, see [`doc/create_release.md`](doc/create_release.md).
For developers that are making changes to or maintaining the release flow, see some additional developer documentation in [`doc/create_release_dev.md`](doc/create_release_dev.md).

For the signing operation, you will need to run [`hsmtool`](https://opentitan.org/earlgrey_1.0.0/book/sw/host/hsmtool/index.html).
At the time of writing, this can be acquired from the [`earlgrey_1.0.0`](https://github.com/lowRISC/opentitan/tree/earlgrey_1.0.0) branch of OpenTitan by running the following from your local copy:

```sh
bazelisk build //sw/host/hsmtool
```

You can either run this directly with `bazelisk run`, or use `bazelisk cquery` to find the output binary and copy it elsewhere.

A separate version of `hsmtool` is also maintained in the [opentitan-signing-infra](https://github.com/lowRISC/opentitan-signing-infra) repository.
To acquire `hsmtool` from this repository, you can run:

```sh
bazelisk build //hsmtool
```

<!-- TODO: update this documentation when the below change has occurred. -->
In the future, it is planned to migrate all OpenTitan implementations to use this separate repository, and the above will be deprecated.

### Testing

This repository is currently still being setup, and as such [SoftHSMv2](https://github.com/softhsm/SoftHSMv2) is being used as a software HSM to **test** the release and signing flows.
If you are intending on using these testing flows, you can find more relevant documentation about configuring SoftHSM [here](skus/open/fake_keygen/README.md).

## Licensing

Unless otherwise noted, everything in this repository is covered by the Apache License, Version 2.0 (see [LICENSES/Apache-2.0.txt](LICENSES/Apache-2.0.txt) for the full text).

## Read More

* [Contribution Guide](CONTRIBUTING.md)
* [Guidance for reporting security vulnerabilities](https://github.com/lowRISC/opentitan/blob/master/SECURITY.md)
* [Guidance for creating release flows](doc/create_release.md)

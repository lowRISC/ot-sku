# Creating a release (developer documentation)

The [release flow](.github/workflows/release.yml) has a few peculiarities which developers should be aware of.
This document lists the most important aspects.

## Self-modifying flow

In order to avoid user errors, the release flow tries to enforce that the same parameters are used for the pre-signing and post-signing flow.
This is achieved by having the release flow modify itself in the release branch to change the default parameters.
Concretely, certains values (which are identified by anchors of the form `<<< ANCHOR >>>`) are modified when doing the pre-signing flow.
This requires more permissions than typically available with the default Github action token and therefore requires a custom token (see below).

## Custom Github token

The release flow requires that a Github token be added to the secrets of the repository under the name `RELEASE_TOKEN`. This token must have
the following rights:
- **Read** access to metadata
- **Read** and **Write** access to code and workflows

## Branch protection

It is highly recommended to set up branch protection so that release branches are automatically protected. The suggested setup
is to automatically protect branches started with `release_`.

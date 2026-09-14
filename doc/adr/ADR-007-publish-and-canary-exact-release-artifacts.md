# ADR-007: Publish and canary exact release artifacts

Date: 2026-09-11

## Status

Accepted

## Supersession Note

ADR-011 supersedes this ADR where it defines exactly one executable release
artifact and one checksum.  ADR-011 expands the publication set to development,
ordinary, and minified executable artifacts with individual checksums.  This ADR
remains authoritative for exact-byte release validation, versioned downstream
pinning, public retrieval, checksum verification, and release-artifact canary
principles except where ADR-011 explicitly expands the asset set.

## Context

ADR-004 established `dist/doxygen-python.awk` and its SHA-256 checksum as the
consumer-artifact boundary while deliberately deferring release publication from
milestone 1.  The sibling `awk-doxygen` and `bash-doxygen` projects validate
maintained source, build the exact distribution artifact, verify its checksum,
and attach both files to semantic-versioned GitHub releases.

Those published release assets are consumed by other repositories through
`bashdeps`.  A consuming repository pins a specific dependency version in its
manifest, together with the public release-asset URL and expected SHA-256 digest.
During that repository's build, `bashdeps` downloads those exact released bytes
and verifies the digest before use.  The consumer does not discover a moving
version and does not require GitHub authentication to retrieve public release
assets.

The user has directed `python-doxygen` to retain as much applicable project
structure as practical from those sibling repositories.  Release publication is
therefore part of the repository's downstream dependency contract and must be
governed explicitly.

## Decision Drivers

- Make the downloadable consumer bytes identical to bytes produced by the tested
  Make build path.
- Preserve the source/dist parity requirement from ADR-004 and ADR-005.
- Give downstream repositories a stable semantic version they can pin.
- Give consumers a checksum that verifies downloaded bytes independently.
- Support public, unauthenticated retrieval by `bashdeps` during downstream
  builds.
- Detect packaging or release-asset failures that a source-tree test cannot see.
- Keep release validation aligned with the same Doxygen integration fixture used
  during development.

## Decision

The versioning workflow SHALL validate maintained source and the generated
consumer artifact before creating a release.  It SHALL use the root Make targets
rather than duplicating build logic in workflow YAML.

For each release, the workflow SHALL:

1. calculate the repository version according to the existing semantic-versioning
   workflow;
2. run the maintained-source semantic suite;
3. build and run the semantic suite against `dist/doxygen-python.awk` with the
   calculated version supplied as build provenance;
4. exercise that generated release candidate through the Python/Doxygen
   integration fixture;
5. generate `dist/doxygen-python.awk.sha256` from that exact artifact;
6. verify the checksum before publication; and
7. attach both `dist/doxygen-python.awk` and
   `dist/doxygen-python.awk.sha256` to the GitHub release.

The published asset names SHALL remain:

```text
doxygen-python.awk
doxygen-python.awk.sha256
```

A downstream `bashdeps` manifest SHALL pin a specific released version rather
than a branch, moving alias, or dynamically discovered latest version.  The
manifest entry SHALL identify the public release-asset URL and the expected
SHA-256 digest.  Retrieval of those public assets is intentionally independent
of GitHub credentials.

A release-artifact canary MAY independently download those exact public assets,
verify the checksum, and run the Doxygen integration fixture with the downloaded
filter.  Such a canary validates publication packaging; it is not part of the
downstream dependency-resolution mechanism.

The released filter SHALL be staged in disposable generated state and SHALL NOT
replace any stable documentation dependency declared in `dependencies-docs.txt`.
A successful release canary SHALL NOT automatically advance dependency pins or
make unrelated repository changes.

This decision supersedes only ADR-004's milestone-1 statement that release
publication is outside scope.  ADR-004's maintained-source name, generated
artifact name, checksum name, comment-only provenance requirement, and
source/dist parity requirements remain governing subject to ADR-011's later
expansion of the generated artifact and checksum set.

## Alternatives Considered

Continuing to create releases without attaching the generated filter was rejected
because the repository already defines a distinct consumer artifact and checksum.
A release that omits those files would create a version tag without publishing
the dependency bytes downstream repositories are expected to pin.

Publishing maintained `doxygen-python.awk` directly was rejected because it would
bypass the generated provenance boundary established by ADR-004.

Having downstream repositories fetch `main`, another moving ref, or an
unversioned URL was rejected because it would make builds non-reproducible and
would defeat the manifest pinning model used by `bashdeps`.

Requiring GitHub authentication for downstream retrieval was rejected because the
release assets are public and the sibling dependency model intentionally uses
ordinary public release URLs plus digest verification.

Automatically updating stable dependency pins after each release was rejected
because dependency advancement is a separate reviewed repository decision.

## Consequences

Release creation now depends on the same Make build and semantic test path used
locally and in pull-request CI.  Consumers receive one executable AWK artifact and
one checksum file whose bytes have been tested together, subject to ADR-011's
later expansion to three executable representations and their checksums.

Downstream repositories can pin an exact semantic version in their `bashdeps`
manifest and reproduce the same dependency bytes later using only the public
release URL and committed digest.

The release workflow has a stronger failure boundary: a semantic failure, build
failure, checksum failure, or asset-publication problem prevents or exposes an
invalid release rather than leaving the discrepancy for consumers to discover.

Future changes to asset names, provenance fields, checksum format, or the
release-publication path are compatibility decisions and require corresponding
ADR review.

## Related Decisions

- ADR-000 requires capability and release claims to match evidence.
- ADR-002 establishes the Doxygen integration representation.
- ADR-004 defines the consumer artifact and checksum boundary and is superseded
  only with respect to its milestone-1 release-publication deferral.
- ADR-005 requires the same semantic suite to exercise maintained and generated
  bytes.
- ADR-006 governs the shared Make and documentation infrastructure.
- ADR-011 expands this ADR's release asset set while preserving its exact-byte
  publication and downstream pinning model.

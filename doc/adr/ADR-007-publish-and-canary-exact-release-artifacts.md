# ADR-007: Publish and canary exact release artifacts

Date: 2026-09-11

## Status

Accepted

## Context

ADR-004 established `dist/doxygen-python.awk` and its SHA-256 checksum as the
consumer-artifact boundary while deliberately deferring release publication from
milestone 1.  The sibling `awk-doxygen` and `bash-doxygen` projects now validate
maintained source, build the exact distribution artifact, verify its checksum,
and attach both files to GitHub releases created by their versioning workflow.
They also validate the exact published bytes after release rather than assuming a
tag checkout is equivalent to the downloadable consumer artifact.

The user has directed `python-doxygen` to retain as much applicable project
structure as practical from those sibling repositories.  Release publication is
therefore no longer merely a future possibility; it is part of the chosen
repository contract and must be governed explicitly.

## Decision Drivers

- Make the downloadable consumer bytes identical to bytes produced by the tested
  Make build path.
- Preserve the source/dist parity requirement from ADR-004 and ADR-005.
- Give consumers a checksum that verifies the downloaded filter independently.
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
4. generate `dist/doxygen-python.awk.sha256` from that exact artifact;
5. verify the checksum before publication; and
6. attach both `dist/doxygen-python.awk` and
   `dist/doxygen-python.awk.sha256` to the GitHub release.

The published asset names SHALL remain:

```text
doxygen-python.awk
doxygen-python.awk.sha256
```

A release-triggered canary SHALL download those exact published assets, verify
the checksum, and run the Doxygen integration fixture with the downloaded filter.
A tag checkout alone is insufficient evidence because the consumer contract
includes packaging and asset publication, not only repository source at a tag.

The released filter SHALL be staged in disposable generated state and SHALL NOT
replace any stable documentation dependency declared in `dependencies-docs.txt`.
A successful release canary SHALL NOT automatically advance dependency pins or
make unrelated repository changes.

This decision supersedes only ADR-004's milestone-1 statement that release
publication is outside scope.  ADR-004's maintained-source name, generated
artifact name, checksum name, comment-only provenance requirement, and
source/dist parity requirements remain governing.

## Alternatives Considered

Continuing to create releases without attaching the generated filter was rejected
because the repository already defines a distinct consumer artifact and checksum.
A release that omits those files would preserve version tags while failing to
publish the contract consumers are expected to use.

Publishing maintained `doxygen-python.awk` directly was rejected because it would
bypass the generated provenance boundary established by ADR-004.

Testing only the release tag was rejected because it cannot detect missing,
incorrectly named, corrupted, or otherwise mispackaged release assets.

Automatically updating stable dependency pins after each release was rejected
because dependency advancement is a separate reviewed repository decision.

## Consequences

Release creation now depends on the same Make build and semantic test path used
locally and in pull-request CI.  Consumers receive one executable AWK artifact and
one checksum file whose bytes have been tested together.

The release workflow has a stronger failure boundary: a semantic failure, build
failure, checksum failure, or asset-publication problem prevents or exposes an
invalid release rather than leaving the discrepancy for consumers to discover.

Future changes to asset names, provenance fields, checksum format, or the
release-validation path are compatibility decisions and require corresponding
ADR review.

## Related Decisions

- ADR-000 requires capability and release claims to match evidence.
- ADR-002 establishes the Doxygen integration representation.
- ADR-004 defines the consumer artifact and checksum boundary and is superseded
  only with respect to its milestone-1 release-publication deferral.
- ADR-005 requires the same semantic suite to exercise maintained and generated
  bytes.
- ADR-006 governs the shared Make and documentation infrastructure.

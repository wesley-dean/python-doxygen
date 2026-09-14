# ADR-004: Build and release a versioned filter

Date: 2026-09-11

## Status

Accepted

## Supersession Note

ADR-007 supersedes only this ADR's milestone-1 deferral of release publication.
ADR-011 supersedes this ADR where it defines one generated artifact and one
checksum, expanding that boundary to development, ordinary, and minified
artifacts with individual checksums.  The maintained-source name, generated-state
model, comment-only provenance principle, and source/artifact parity requirements
remain governing except where ADR-011 explicitly expands them.

## Context

Consumers need one inspectable filter artifact whose bytes can be tested and
verified independently of the maintained source tree.  Sibling Doxygen filters
already separate maintained source from a generated artifact with comment-only
provenance.

## Decision

The maintained source SHALL be `doxygen-python.awk`.  `make build` SHALL produce
`dist/doxygen-python.awk`, and `make checksums` SHALL produce
`dist/doxygen-python.awk.sha256`.

The generated artifact SHALL contain comment-only provenance fields for version,
build date, and source commit.  Provenance MUST NOT create executable AWK state or
change record-processing behavior.

The same semantic regression suite SHALL run against maintained source and the
built artifact.  The generated `dist/` directory remains untracked build state.
Release publication was outside milestone 1 and was not implemented merely by
establishing this artifact contract; ADR-007 subsequently governs release
publication of the tested artifact and checksum.

## Alternatives Considered

Releasing maintained source directly was rejected because it loses the explicit
consumer-artifact and provenance boundary.  Executable AWK variables for build
metadata were rejected because provenance must not alter runtime semantics.

## Consequences

Local development and release automation share one canonical build path.  Any
build transformation is tested for semantic parity before the artifact is
considered usable.

## Related Decisions

- ADR-000 governs capability claims.
- ADR-005 requires source and dist parity in the regression suite.
- ADR-007 governs release publication and exact released-artifact validation.
- ADR-011 expands the generated artifact and checksum set while preserving this
  ADR's underlying source/artifact boundary.

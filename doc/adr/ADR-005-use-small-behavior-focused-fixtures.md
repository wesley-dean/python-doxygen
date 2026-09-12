# ADR-005: Use small behavior-focused regression fixtures

Date: 2026-09-11

## Status

Accepted

## Context

The filter deliberately recognizes a narrow Python documentation subset.  Large
integration samples make it difficult to determine which parser contract failed
and can accidentally couple tests to helper implementation.

## Decision

Regression coverage SHALL use small fixtures, each answering one narrow behavior
question.  Successful inputs live in `tests/python/fixtures/` with golden filtered
outputs in `tests/python/expected/`.  Diagnostic cases live under
`tests/python/diagnostics/` with stable expected warning text.

The suite SHALL protect module, class, function, and method docstring recognition;
parameter, return, and exception translation; ordinary source pass-through;
runtime triple-string non-recognition; malformed supported syntax; strict-mode
failure; and source-line preservation where practical.

The exact same semantic suite SHALL run against maintained source and generated
consumer bytes.  Tests SHALL protect externally observable behavior rather than
helper names or internal state-machine structure.

At least one integration fixture SHALL be processed by Doxygen so the project can
distinguish syntactically plausible filtered output from output Doxygen actually
uses as intended.

## Alternatives Considered

A few large representative programs were rejected because failures would be less
localized and parser-boundary changes harder to review.  Tests tied to internal
helpers were rejected because implementation refactoring should not change the
public contract.

## Consequences

The fixture count may grow as support expands, but each new syntax claim should
have a focused executable example.  Source and release-artifact drift becomes a
test failure rather than a documentation-only discrepancy.

## Related Decisions

- ADR-001 defines the parser boundary the fixtures protect.
- ADR-002 governs the Doxygen integration representation.
- ADR-004 defines the source/dist artifact boundary.

# ADR-008: Add scenario-level program regressions

Date: 2026-09-11

## Status

Accepted

## Context

ADR-005 established small, behavior-focused fixtures as the regression-testing
foundation.  That decision makes failures easy to localize and requires each new
syntax claim to have a focused executable example.  The milestone-1 filter now
also has enough interacting parser state that isolated fixtures alone provide
limited evidence about recovery across longer, realistic source files.

Examples include a declaration followed by comments and blank lines, a supported
docstring followed by runtime triple-quoted data, unsupported raw docstrings,
adjacent declarations, decorators, asynchronous functions, and mixtures of
supported and unsupported documentation fields.  Each behavior can pass in
isolation while a state transition between them still fails.

## Decision

The project SHALL retain the small fixtures required by ADR-005 and SHALL add a
supplementary scenario-level regression layer containing larger Python programs.
These programs SHALL exercise multiple already-governed behaviors in realistic
sequences without expanding the supported Python syntax boundary.

Larger program inputs SHALL live under `tests/python/programs/` with corresponding
golden filtered output under `tests/python/programs-expected/`.  They SHALL run
through the same semantic harness as the focused fixtures and therefore SHALL be
exercised against both maintained source and generated consumer artifacts under
the existing AWK implementation matrix.

Each larger program SHALL still have a primary testing purpose so failures remain
reviewable.  The initial scenarios cover service-style class and function
interactions, asynchronous declarations with mixed supported and unsupported
fields, and conservative parser-boundary recovery around runtime strings, raw
docstrings, decorators, and adjacent declarations.

ADR-008 supersedes only ADR-005's rejection of supplementary larger representative
programs.  It does not weaken ADR-005's requirement for focused fixtures, golden
outputs, stable diagnostics, line preservation, source/dist parity, or public
behavior testing.

## Alternatives Considered

Replacing the focused fixtures with larger programs was rejected because it would
make failures harder to localize and would weaken the executable specification of
individual syntax claims.

Leaving coverage entirely at the focused-fixture level was rejected because it
would not directly exercise longer state-machine transitions and recovery between
multiple valid and intentionally unsupported constructs in one source file.

Adding a separate test runner for the larger programs was rejected because the
existing semantic harness already defines the source/dist contract.  Running both
layers through one harness reduces the chance that one artifact receives weaker
coverage.

## Consequences

The regression suite becomes slower by a small amount and golden output grows,
but the project gains evidence that governed behaviors compose correctly across
more realistic source files.  Focused fixtures remain the first place to encode a
new syntax claim, while scenario programs protect interactions among claims that
have already been accepted.

No parser capability is added by this decision.  Any scenario that requires new
recognition semantics still requires the focused fixtures and governance changes
that would have been required before ADR-008.

## Related Decisions

- ADR-001 defines the supported Python documentation boundary.
- ADR-002 governs the source-preserving Doxygen representation.
- ADR-004 defines the source/dist artifact boundary.
- ADR-005 remains authoritative for focused behavior fixtures and is superseded
  only where it rejected supplementary larger representative programs.
- ADR-006 governs the shared source/dist test infrastructure.

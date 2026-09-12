# ADR-003: Define yields translation

Date: 2026-09-11

## Status

Accepted

## Context

The Python documentation standard uses `:yields:` for generator output.  An
ordinary function return is not the same semantic contract as a sequence of
values produced by a generator.

## Decision

Milestone 1 SHALL NOT translate `:yields:`.  The field SHALL remain visible and
unchanged in filtered source.

A later milestone may establish a Doxygen representation after an integration
experiment demonstrates the generated documentation and the representation does
not falsely describe generator semantics.  That change requires this ADR to be
updated or superseded and protected by focused fixtures.

## Alternatives Considered

Mapping yields directly to a return command was rejected because it would blur
generator and ordinary-return semantics.  A custom command was rejected because
no consumer configuration or rendering contract has yet been established.

## Consequences

Generator documentation remains Python-native and visible, while milestone 1
makes no structured Doxygen-rendering claim for yielded values.

## Related Decisions

- ADR-000 requires planned and implemented support to remain distinct.
- ADR-001 defines the milestone-1 structured-field subset.

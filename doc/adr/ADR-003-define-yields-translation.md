# ADR-003: Define yields translation

Date: 2026-09-11

## Status

Accepted

## Context

The Python documentation standard uses `:yields:` for generator output.  An
ordinary function return is not the same semantic contract as a sequence of
values produced by a generator.

Milestone 1 therefore left `:yields:` unchanged pending a Doxygen integration
experiment.  Issue #5 supplied that experiment with Doxygen command parsing
enabled under ADR-002.  The experiment demonstrated that a dedicated Doxygen
paragraph titled `Yields` preserves generator semantics without describing the
value as an ordinary function return.

The experiment also demonstrated that Doxygen command paragraphs naturally keep
adjacent continuation prose associated with the preceding command until a blank
line or another sectioning command.  That permits existing structured-field
continuation lines to remain byte-preserved.

## Decision

The filter SHALL translate a well-formed `:yields:` field into a dedicated
Doxygen paragraph titled `Yields`.  The field description SHALL appear as the
paragraph body rather than as return documentation.

The translation may add one physical output line for each translated `:yields:`
field because Doxygen's paragraph command requires the title and body to be
separate for the intended generated structure.  This is an explicit exception
to the preferred one-input-line-to-one-output-line correspondence in ADR-002.
No broader permission to change physical line count is implied.

Continuation prose following supported `:param`, `:returns:`, `:raises`, and
`:yields:` fields SHALL remain unchanged when Doxygen can preserve the intended
association without additional translation state.

Malformed `:yields:` fields SHALL follow the existing diagnostic model: emit a
warning, preserve the original input, and fail only when strict mode is active.

## Alternatives Considered

Mapping yields to return documentation was rejected because generator yields are
not ordinary function returns.

A custom Doxygen alias was rejected because it would add a consumer-side Doxyfile
configuration dependency when the built-in paragraph representation is adequate.

Leaving `:yields:` permanently untranslated was rejected because the integration
experiment established a faithful built-in representation.

Encoding the title and description on one generated line was rejected because it
did not produce the intended paragraph structure.

## Consequences

Generator output receives a distinct Doxygen-rendered `Yields` section.  A
translated `:yields:` field increases filtered output by one physical line, so
source-line correspondence after that field is shifted by one line.  Other
supported structured fields continue to preserve physical line count, and their
continuation prose remains unchanged.

Focused semantic fixtures and Doxygen integration assertions SHALL protect the
yields representation and continuation behavior.

## Related Decisions

- ADR-000 requires capability claims to match evidence.
- ADR-001 defines the original structured-field translation boundary.
- ADR-002 governs the source-preserving representation and Doxygen configuration.
- ADR-005 requires focused fixtures plus Doxygen integration evidence.

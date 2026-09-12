# ADR-009: Expand standards-conforming docstring recognition

Date: 2026-09-11

## Status

Accepted

## Context

ADR-001 established a deliberately narrow milestone-1 recognition boundary so
the project could prove the source-preserving Doxygen architecture without
claiming broad Python parsing capability.  The canonical Python documentation
standard now requires or permits documentation forms that milestone 1 leaves
outside that boundary, including raw triple-double-quoted docstrings when
backslashes are intended literally and PEP 257-compatible one-line docstrings.

The current filter also recognizes `def`, `async def`, and `class` declarations
only from their first physical line and immediately looks for the suite's first
statement.  A conventional multi-line declaration therefore loses pending suite
state before its docstring is reached.

Issue #5 requires closing these gaps while preserving ADR-000's capability-honesty
rule and ADR-002's source-preserving representation.  Portable AWK remains the
implementation constraint; this decision does not authorize a complete Python
lexer or parser.

## Decision Drivers

- Make standards-conforming maintained Python receive predictable Doxygen
  treatment without a second authoring dialect.
- Support the raw docstring form explicitly required by the canonical standard.
- Support conventional multi-line declarations used by formatters and human
  maintainers.
- Preserve runtime string literals and ambiguous source rather than guessing.
- Keep the recognition algorithm inspectable and portable across `mawk` and GNU
  awk.
- Keep signature and semantic validation with Python-native tooling.

## Decision

The filter SHALL recognize triple-double-quoted docstrings in the same governed
module and suite positions established by ADR-001, with the following expanded
boundary.

Supported opening forms are exactly:

```text
"""
r"""
R"""
```

The raw prefixes are supported because the canonical standard explicitly calls
for raw triple-double-quoted docstrings when backslashes are intended literally.
Other Python string prefixes and prefix combinations remain outside the supported
recognition boundary unless the canonical documentation standard later requires
them or a separate accepted ADR establishes a need.  Unsupported prefixed strings
remain visible source and SHALL NOT be reclassified speculatively.

One-line prose docstrings using a supported opening form SHALL be recognized
deterministically when they occur in an otherwise governed module or suite
docstring position.  This decision does not introduce one-line structured-field
syntax; structured-field translation remains governed separately.

For `def`, `async def`, and `class` declarations, the filter SHALL retain pending
declaration state across conventional multi-line headers.  A declaration header
is considered complete when a physical source line, after removal of trailing
horizontal whitespace, ends with the suite-opening colon.  Once the header is
complete, blank and comment-only lines may precede the suite's first statement as
under ADR-001.

This rule intentionally avoids bracket balancing, string parsing, annotation
interpretation, and decorator semantics.  If a legal declaration cannot be
identified safely by this conservative boundary, the filter SHALL prefer a false
negative and preserve source unchanged.

The filter SHALL continue to treat triple-quoted strings that occur after another
statement in a suite as runtime source rather than documentation.  Broadened raw
docstring recognition must have regression coverage proving that raw or ordinary
runtime strings are not rewritten merely because their delimiters resemble a
supported docstring.

Delimiter handling for supported raw docstrings SHALL remain conservative.  The
filter may recognize only delimiter cases it can distinguish safely without
implementing Python string-literal semantics.  Ambiguous escaped-delimiter cases
must remain visible and must not receive structured translation unless focused
fixtures and an accepted decision establish safe handling.

The filter SHALL NOT use broadened recognition as a basis for validating parameter
names, inferring return behavior, inferring exceptions, inferring types, or
interpreting decorators.  Those concerns remain delegated to Python-native tools
unless separately governed.

ADR-009 supersedes ADR-001 only where ADR-001 limits docstring recognition to
unprefixed forms, treats one-line support as merely optional, and assumes a
single-physical-line declaration header.  ADR-001 remains authoritative for the
conservative documentation-position rule, runtime-string protection, diagnostic
philosophy, unsupported-markup visibility, and milestone-1 structured-field
semantics until those portions are separately superseded.

## Alternatives Considered

Supporting every Python string prefix was rejected because the canonical standard
does not require that breadth, and doing so would expand lexical complexity
without a documentation-contract benefit.

Using a Python parser or tokenizer as a required preprocessing dependency was
rejected because portable AWK remains the project's governed compatibility floor
and the filter is intended to remain a small documentation translator.

Balancing parentheses, brackets, braces, strings, and comments to locate the end
of a declaration was rejected for this step because it would move the AWK filter
substantially closer to reimplementing Python lexical analysis.  The
line-ending-colon rule covers conventional formatted declarations while retaining
an inspectable false-negative bias.

Continuing to reject raw docstrings and multi-line declarations was rejected
because those forms are compatible with the canonical standard and would force
maintainers to learn filter-specific authoring restrictions.

## Consequences

Standards-conforming raw docstrings and conventional multi-line declarations gain
a governed path to Doxygen translation.  One-line prose docstrings become a tested
contract rather than incidental behavior.

Some legal Python forms remain intentionally unsupported when recognizing them
would require substantially deeper lexical analysis.  That is compatible with
ADR-000 so long as the project documents those boundaries and does not claim
support without evidence.

Focused regression fixtures are required for ordinary and raw module docstrings,
class/function/method docstrings after multi-line declarations, one-line prose
docstrings, unsupported prefixes, and runtime-string non-recognition.  The same
coverage must run against maintained and generated consumer artifacts under both
supported AWK implementations.

This decision does not establish translations for `:yields:`, `:type:`, `:rtype:`,
or structured-field continuation text.  Those representations require separate
integration evidence and governance.

## Related Decisions

- ADR-000 requires capability honesty and conservative claims.
- ADR-001 remains authoritative except where explicitly superseded here.
- ADR-002 requires the source-preserving Doxygen representation.
- ADR-003 reserves `:yields:` for an integration-backed representation decision.
- ADR-005 requires focused behavior fixtures.
- ADR-008 permits supplementary scenario-level program regressions.

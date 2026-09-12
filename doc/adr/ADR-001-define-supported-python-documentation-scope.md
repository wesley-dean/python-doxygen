# ADR-001: Define supported Python documentation scope

Date: 2026-09-11

## Status

Accepted

## Context

`python-doxygen` translates Python-native documentation at the Doxygen boundary.
A portable AWK filter cannot safely become a complete Python lexer or parser, so
the initial recognition boundary must be explicit before implementation.

## Decision Drivers

- Preserve Python-native documentation as maintained source.
- Prefer false negatives to false semantic claims.
- Keep the first parser small, inspectable, and portable.
- Protect runtime triple-quoted strings from accidental rewriting.
- Preserve unsupported markup visibly rather than inventing meaning.

## Decision

Milestone 1 SHALL recognize triple-double-quoted module, class, function, and
method docstrings.  A recognized docstring must occur in a position where a
Python docstring can begin: at module scope before ordinary module statements, or
as the first statement in the suite of a recognized `class`, `def`, or
`async def` declaration.

The initial filter SHALL recognize declarations conservatively.  Decorator lines
may precede a function or class declaration, but broad decorator semantics are
outside scope.  A triple-quoted string appearing after another statement in a
suite SHALL be treated as runtime source and SHALL NOT be translated.

Milestone 1 SHALL support multi-line triple-double-quoted docstrings and MAY
support a one-line prose-only triple-double-quoted docstring when recognition is
unambiguous.  Raw or other prefixed docstrings are outside the initial supported
subset.  Other quote styles and arbitrary prefix combinations are unsupported.

Within a recognized docstring, these fields are supported:

```text
:param name: description
:returns: description
:raises ExceptionType: description
```

A supported field occupies one physical line in milestone 1.  Indented
continuation prose remains visible but is not semantically attached to the field.
A continuation form that appears to require semantic association SHALL produce a
diagnostic rather than being guessed.

Unsupported reStructuredText SHALL pass through unchanged.  `:yields:` remains
unchanged until ADR-003 establishes a translation contract.

Malformed syntax resembling a supported field SHALL produce a diagnostic.  In
normal mode the source remains visible and processing continues when safe.  In
`--strict` mode any diagnostic causes a non-zero final status.

When docstring identity is ambiguous, the filter SHALL leave the source unchanged
rather than classify the string as documentation.

The filter SHALL NOT validate documented names against Python signatures, infer
return behavior, infer exceptions, infer types, or claim complete Python parsing.

## Considered Alternatives

A general Python parser was rejected because portable AWK is the implementation
constraint and the product is a documentation translator.  Rewriting every
triple-quoted string was rejected because ordinary runtime strings are valid
Python and must not be changed merely because their syntax resembles a docstring.

Supporting all Python string prefixes immediately was rejected because prefix
lexing adds complexity without being necessary to prove the translation model.
Semantic signature validation was rejected because Python-native linters are
better positioned to perform it.

## Consequences

The initial implementation intentionally leaves valid Python documentation forms
unsupported.  Those false negatives are preferable to silently rewriting runtime
source or claiming semantics the filter cannot establish.  New syntax requires
focused fixtures and, when it changes the parser boundary materially, updated
governance.

## Related Decisions

- ADR-000 requires capability honesty and conservative claims.
- ADR-002 governs the Doxygen-facing representation.
- ADR-003 reserves `:yields:` for an explicit decision.
- ADR-005 governs behavior-focused fixtures.

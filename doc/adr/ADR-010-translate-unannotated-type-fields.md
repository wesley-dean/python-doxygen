# ADR-010: Translate unannotated type fields

Date: 2026-09-11

## Status

Accepted

## Context

The canonical Python documentation standard treats type annotations as the
preferred machine-readable type contract.  It permits `:type name:` and
`:rtype:` only when a maintained interface intentionally lacks annotations and
type information is useful to linting or generated documentation.

Doxygen does not provide a Python-specific command that faithfully represents
Sphinx `:type:` or `:rtype:` fields.  Folding the type into `@param` or `@return`
would mix maintained type assertions with descriptive contract prose, while
Doxygen's typed-parameter syntax is not a general Python representation.

Issue #5 therefore tested a neutral Doxygen representation using titled
paragraphs.  With the ADR-002 integration configuration in place, Doxygen
successfully generated a `Type of path` paragraph containing `pathlib.Path` and
a `Return type` paragraph containing `Configuration`.

The filter deliberately does not parse Python signatures deeply enough to decide
whether an interface is annotated.  That semantic validation remains with
Python-native tooling and repository policy.

## Decision

A well-formed `:type name: value` field SHALL be translated to a dedicated
Doxygen paragraph titled `Type of name`, with the maintained type value as the
paragraph body.

A well-formed `:rtype: value` field SHALL be translated to a dedicated Doxygen
paragraph titled `Return type`, with the maintained type value as the paragraph
body.

Each translation may add one physical output line because Doxygen's paragraph
representation requires the title and body to be separate.  This is the same
bounded line-correspondence tradeoff accepted for `:yields:` by ADR-003.  It does
not authorize unrelated line-count changes.

The filter SHALL translate these fields when they occur inside a recognized
docstring.  It SHALL NOT attempt to determine whether annotations are also
present, infer types from signatures, reconcile conflicts, or remove redundant
type documentation.  Those concerns remain delegated to Python-native linters and
the maintained-source standard.

Malformed `:type:` and `:rtype:` forms SHALL follow the established diagnostic
model: emit a warning, preserve the original source line, and fail only in strict
mode.

## Alternatives Considered

Leaving the fields permanently unchanged was rejected because the canonical
standard permits them for intentionally unannotated interfaces and the Doxygen
experiment demonstrated a faithful built-in representation.

Folding type values into `@param` or `@return` was rejected because it conflates
type assertions with descriptive parameter and return semantics.

Using a custom Doxygen alias was rejected because the built-in paragraph command
already provides the required representation without adding consumer-side
configuration.

Parsing annotations to suppress or validate `:type:` and `:rtype:` was rejected
because that would widen the AWK filter into semantic Python analysis that belongs
with Python-native tooling.

## Consequences

Intentionally unannotated interfaces can carry their maintained type information
into generated Doxygen output without inventing Python signature semantics.
Translated `:type:` and `:rtype:` fields each add one physical output line, while
ordinary prose and previously governed fields retain their established behavior.

Focused semantic fixtures, malformed-field diagnostics, and Doxygen integration
assertions SHALL protect the representation.  Capability documentation must make
clear that the filter translates maintained type fields; it does not validate
whether those fields are appropriate for a particular Python signature.

## Related Decisions

- ADR-000 requires evidence-oriented capability claims and prohibits unsupported
  inference.
- ADR-001 established the original structured-field boundary.
- ADR-002 governs the source-preserving Doxygen representation and integration
  configuration.
- ADR-003 establishes the bounded line-expansion precedent for titled paragraphs.
- ADR-005 requires focused semantic and integration evidence.
- ADR-009 preserves the conservative non-parser recognition boundary.

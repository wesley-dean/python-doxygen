# Architecture Decisions

## Capability scope and epistemic honesty

The project distinguishes implemented behavior from planned behavior and makes
capability claims only when evidence supports them.  The filter must remain clear
about uncertainty and must not present itself as a complete Python parser.  See
[ADR-000](adr/ADR-000-capability-scope-and-epistemic-honesty.md).

## Supported Python documentation scope

Milestone 1 recognizes only conservatively identifiable triple-double-quoted
module, class, function, and method docstrings and translates three structured
field forms.  Ambiguous strings remain source rather than being guessed to be
documentation.  See
[ADR-001](adr/ADR-001-define-supported-python-documentation-scope.md).

## Doxygen-facing representation

Doxygen successfully parsed the source-preserving experiment and generated XML
containing translated prose, parameter, return, and exception documentation.  The
filter therefore preserves Python declarations and docstrings while translating
only supported field lines.  See
[ADR-002](adr/ADR-002-preserve-python-and-translate-docstrings.md).

## Yields translation

Milestone 1 leaves `:yields:` unchanged rather than equating generator yields with
ordinary return semantics.  A later structured representation requires evidence
and an updated or superseding decision.  See
[ADR-003](adr/ADR-003-define-yields-translation.md).

## Versioned consumer artifact

Maintained source and consumer bytes are separate.  `make build` produces
`dist/doxygen-python.awk` with comment-only provenance, and the same semantic
suite exercises source and dist.  See
[ADR-004](adr/ADR-004-build-and-release-versioned-filter.md).

## Behavior-focused fixtures

Regression coverage uses small fixtures that each protect a narrow public
behavior.  Golden output, diagnostics, runtime-string non-recognition, and
source/dist parity define the supported contract rather than helper structure.
See [ADR-005](adr/ADR-005-use-small-behavior-focused-fixtures.md).

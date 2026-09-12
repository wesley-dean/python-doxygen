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

ADR-002 is intentionally pending the required Doxygen experiment.  The preferred
model is source-preserving Python with translated field contents, but it must not
be accepted until generated Doxygen output proves that representation works.

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

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
suite exercises source and dist.  ADR-007 later supersedes only ADR-004's initial
deferral of release publication; the artifact boundary remains unchanged.  See
[ADR-004](adr/ADR-004-build-and-release-versioned-filter.md).

## Behavior-focused fixtures

Regression coverage retains small fixtures that each protect a narrow public
behavior.  Golden output, diagnostics, runtime-string non-recognition, and
source/dist parity define the supported contract rather than helper structure.
ADR-008 supplements these fixtures with larger program-level scenarios without
replacing their role.  See
[ADR-005](adr/ADR-005-use-small-behavior-focused-fixtures.md).

## Shared project infrastructure

ADR-006 directs the repository to adopt the applicable Make, regression-test,
pinned documentation dependency, generated ADR navigation, Doxygen reference,
and Pages-publication patterns from `awk-doxygen` and `bash-doxygen`.  Those
patterns are now represented by Make-driven source/dist testing, a separate
Python/Doxygen integration fixture, `bashdeps`-managed documentation dependencies,
generated ADR navigation, reference-document generation, documentation canaries,
and Pages deployment.  Sibling interfaces without a coherent Python purpose,
such as `--compact`, are deliberately not copied.  See
[ADR-006](adr/ADR-006-adopt-sibling-build-test-and-documentation-infrastructure.md).

## Release publication and downstream pinning

ADR-007 requires semantic-version releases to publish the tested
`doxygen-python.awk` artifact and its SHA-256 checksum as public release assets.
Downstream repositories pin a specific version, public release URL, and digest in
their `bashdeps` manifests; their builds retrieve and verify those exact bytes
without GitHub authentication or version discovery.  Release-artifact canaries
may independently verify publication packaging, but they are not part of the
downstream dependency-resolution path.  See
[ADR-007](adr/ADR-007-publish-and-canary-exact-release-artifacts.md).

## Scenario-level program regressions

The regression suite also includes larger Python programs that combine previously
governed behaviors in realistic sequences.  These scenarios exercise longer
parser-state transitions and recovery while the small ADR-005 fixtures remain the
primary executable specification for individual syntax claims.  The same harness
runs both layers against maintained source and generated consumer bytes.  See
[ADR-008](adr/ADR-008-add-scenario-level-program-regressions.md).

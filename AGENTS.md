# AGENTS.md

## Repository Purpose

`python-doxygen` provides a documentation-led Doxygen input filter for Python.
Maintained Python remains idiomatic Python; the filter translates supported
docstring syntax only at the Doxygen boundary.

The maintained filter is `doxygen-python.awk`.  It is a documentation translator,
not a complete Python parser.  Capability claims must match tests and accepted
ADRs.

## Governing Documentation

Before changing the repository, review `README.md`, this file,
`doc/documentation-standard.md`, `doc/awk-documentation-standard.md`, every ADR
in `doc/adr/*.md`, and `doc/decisions.md`.

Accepted ADRs are governance.  Consequential parser, interface, portability,
compatibility, documentation-publication, or release changes require an ADR
unless existing governance already covers the decision.

## Documentation Standards

The authoritative Python standard is
`wesley-dean/coding_standards/standards/python/documentation-standard.md`.
`doc/documentation-standard.md` records this repository's adoption point.  Do
not independently rewrite or weaken the canonical Python contract here.

Maintained AWK source follows `doc/awk-documentation-standard.md`, the checked-in
AWK documentation standard supplied for this repository.  Its canonical upstream
is `wesley-dean/coding_standards/standards/awk/documentation-standard.md`.
Documentation changes to `doxygen-python.awk` must preserve executable behavior
unless the change is separately governed and tested as a behavior change.

## Architecture and Scope

Preserve Python-native documentation as the human- and linter-facing source of
truth.  Do not require Doxygen-specific Python docstrings or duplicate Doxygen
comment blocks.  ADR-002 establishes the source-preserving Doxygen representation
based on an executable integration experiment.

The filter is intentionally narrow.  Prefer false negatives and visible
unsupported syntax to speculative semantic claims.  Do not add signature
validation, type inference, inferred behavior, broad decorator semantics, or
complete Python parsing without explicit governance.

`:yields:` is outside milestone 1 under ADR-003.

## Portability and Testing

Portable AWK is the compatibility floor.  Production filter source must run under
at least `mawk` and GNU awk.

Behavior-focused fixtures live under `tests/python/`.  Fixtures protect public
behavior, not helper structure.  The same semantic suite must run against
maintained `doxygen-python.awk` and all generated executable artifacts:
`dist/doxygen-python.dev.awk`, `dist/doxygen-python.awk`, and
`dist/doxygen-python.min.awk`.

Run `make check` to apply GNU awk fatal linting to maintained root AWK sources.
Linting remains intentionally separate from semantic testing.  After preparing
build dependencies with `make deps`, use `make test AWK_BIN=mawk` and
`make test AWK_BIN=gawk`; the test harness emits one TAP-compliant stream across
all selected filter variants.  Preserve source-line correspondence where
practical, and pass ordinary Python source outside translated docstrings through
unchanged.  `make test-doxygen` exercises one selected Python filter, while
`make test-doxygen-dist` exercises all generated release candidates.

## Build Dependencies

Build dependencies are pinned in `dependencies.txt` and materialized beneath
`vendor/` by the SHA-256-pinned `bashdeps` bootstrap.  ADR-011 requires an exact,
digest-verified `awk-minifier` release for minified artifact generation.

`make deps` may use the network.  `make deps-check` and `make build` consume
prepared state without silently downloading, repairing, or advancing pins.  The
canonical build must fail clearly if its prepared minifier dependency is missing
or invalid.

## Documentation Tooling

Project reference documentation describes this repository's maintained AWK,
Bash, Markdown, and ADR sources.  It is distinct from the Python-filter integration
test.

Documentation-only dependencies are pinned separately in `dependencies-docs.txt`
and are materialized beneath `vendor/` by the same pinned `bashdeps` bootstrap.
The set includes released `awk-doxygen`, released `bash-doxygen`, and released
`adrctl`.  `make deps-docs` may use the network; `make deps-docs-check`,
`make adr-index`, and `make docs` consume prepared state without silently
repairing or advancing dependency pins.

Generated `doc/adr/README.md`, `doc/reference/`, `dist/`, and `vendor/` state is
disposable and must remain ignored by Git.

## Build and Release

The maintained source is `doxygen-python.awk`.  ADR-011 governs three generated
executable representations: `dist/doxygen-python.dev.awk` preserves the documented
body, `dist/doxygen-python.awk` removes full-line comments while retaining the
established default consumer filename, and `dist/doxygen-python.min.awk` is
produced by the pinned minifier.  `make checksums` produces one SHA-256 file for
each executable artifact.

`make build` is the canonical offline artifact build.  Generated provenance is
owned by the build, remains comments only, and must be kept outside body
transformations so comment stripping or minification cannot erase provenance or
introduce executable AWK state.

Semantic-version releases are a downstream dependency interface.  The versioning
workflow must validate maintained and generated bytes, exercise all generated
variants through Doxygen, verify all three checksums, and publish all six governed
files.  Other repositories may pin any exact released executable asset with
`bashdeps`; `doxygen-python.awk` remains the default compatibility path.

Exact published release bytes must be checksum-verified and exercised through the
Python/Doxygen integration fixture.  Do not substitute a tag checkout for this
asset-level validation.

## Engineering Approach

Keep changes surgical and reviewable.  Accuracy is more important than apparent
completeness.  Distinguish implemented behavior from planned behavior, state
uncertainty explicitly, and do not widen the parser boundary without governance
and focused fixtures.
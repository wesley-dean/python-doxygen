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
`doc/documentation-standard.md`, the canonical AWK documentation standard, every
ADR in `doc/adr/*.md`, and `doc/decisions.md`.

Accepted ADRs are governance.  Consequential parser, interface, portability,
compatibility, or release changes require an ADR unless existing governance
already covers the decision.

## Documentation Standards

`doc/documentation-standard.md` is synchronized from
`wesley-dean/coding_standards/standards/python/documentation-standard.md`.  Do not
edit the synchronized copy locally.

The AWK filter follows
`wesley-dean/coding_standards/standards/awk/documentation-standard.md`.

## Architecture and Scope

Preserve Python-native documentation as the human- and linter-facing source of
truth.  Do not require Doxygen-specific Python docstrings or duplicate Doxygen
comment blocks.

The filter is intentionally narrow.  Prefer false negatives and visible
unsupported syntax to speculative semantic claims.  Do not add signature
validation, type inference, inferred behavior, broad decorator semantics, or
complete Python parsing without explicit governance.

`:yields:` is outside milestone 1 until ADR-003 establishes its representation.

## Portability and Testing

Portable AWK is the compatibility floor.  Production filter source must run under
at least `mawk` and GNU awk.

Behavior-focused fixtures live under `tests/python/`.  Fixtures protect public
behavior, not helper structure.  The same semantic suite must run against
maintained `doxygen-python.awk` and generated `dist/doxygen-python.awk`.

Use `make test AWK_BIN=mawk` and `make test AWK_BIN=gawk`.  Preserve source-line
correspondence where practical, and pass ordinary Python source outside translated
docstrings through unchanged.

## Build and Release

The maintained source and consumer outputs are `doxygen-python.awk`,
`dist/doxygen-python.awk`, and `dist/doxygen-python.awk.sha256`.  `make build` is
the canonical artifact build.  Build provenance is comments only and must not add
executable AWK state.

## Engineering Approach

Keep changes surgical and reviewable.  Accuracy is more important than apparent
completeness.  Distinguish implemented behavior from planned behavior, state
uncertainty explicitly, and do not widen the parser boundary without governance
and focused fixtures.

# ADR-002: Preserve Python and translate docstrings

Date: 2026-09-11

## Status

Proposed

## Context

The preferred product model preserves Python declarations and changes only
structured field syntax inside recognized docstrings.  That representation is
attractive because it keeps the filtered stream close to maintained source and
preserves line correspondence, but it is valid only if Doxygen associates an
ordinary Python docstring containing translated commands with the documented
Python entity.

The required experiment uses
`tests/python/fixtures/00-doxygen-experiment.py` and the manually translated
candidate in `tests/python/expected/00-doxygen-experiment.py`.

## Decision Drivers

- Keep Python parsing with Doxygen rather than synthesizing another language.
- Preserve source lines where practical.
- Avoid Doxygen-specific syntax in maintained Python.
- Base the representation on generated Doxygen evidence rather than assumption.

## Proposed Decision

If the integration experiment proves that Doxygen associates the translated
ordinary docstring with `normalize()` and renders its prose, parameter, return,
and exception documentation, the project SHALL preserve Python source and
translate only supported docstring field lines.

If that experiment fails, this ADR SHALL NOT be accepted.  The project will
record the observed failure and choose the smallest alternative representation
that Doxygen demonstrably understands.

The implementation branch may contain the candidate translator and regression
fixtures while this experiment is evaluated, but the representation is not an
accepted project capability until the Doxygen integration check passes.

## Alternatives Considered

Requiring Doxygen-specific docstrings in maintained Python is rejected because it
violates the canonical Python documentation standard.  Synthesizing pseudo-C++
without evidence that it is necessary is rejected because it discards Python's
native declaration model and increases transformation scope.

Converting docstrings to Python documentation comments remains a fallback only if
an experiment proves source-preserving docstrings inadequate; association and
line-correspondence consequences would need explicit evaluation.

## Consequences

ADR-002 remains deliberately Proposed until executable Doxygen evidence exists.
The draft pull request must not describe the preferred representation as proven
while this status remains Proposed.

## Related Decisions

- ADR-000 requires evidence-oriented capability claims.
- ADR-001 defines which docstrings and fields may be translated.
- ADR-005 requires an integration fixture in addition to golden text output.

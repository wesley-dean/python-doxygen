# ADR-002: Preserve Python and translate docstrings

Date: 2026-09-11

## Status

Accepted

## Context

The product model preserves Python declarations and changes only structured field
syntax inside recognized docstrings.  This keeps the filtered stream close to
maintained source and preserves line correspondence, but it is valid only if
Doxygen associates an ordinary Python docstring containing translated commands
with the documented Python entity.

The required experiment uses
`tests/python/fixtures/00-doxygen-experiment.py` and the manually translated
candidate in `tests/python/expected/00-doxygen-experiment.py`.

## Decision Drivers

- Keep Python parsing with Doxygen rather than synthesizing another language.
- Preserve source lines where practical.
- Avoid Doxygen-specific syntax in maintained Python.
- Base the representation on generated Doxygen evidence rather than assumption.

## Decision

The project SHALL preserve Python declarations and ordinary triple-double-quoted
docstrings in the filtered stream.  Within docstrings recognized under ADR-001,
the filter SHALL translate only the supported structured field lines and leave
ordinary prose and surrounding Python source in place.

The representation experiment executed Doxygen against the manually translated
candidate and verified generated XML contained the function prose, parameter
description, return description, and exception information.  The subsequent
integration job ran Doxygen through the maintained `doxygen-python.awk` filter and
verified the same information in generated XML.  Both checks succeeded on
2026-09-11 in pull request #4.

## Alternatives Considered

Requiring Doxygen-specific docstrings in maintained Python was rejected because
it violates the canonical Python documentation standard.  Synthesizing pseudo-C++
was rejected because the experiment demonstrated that Doxygen can continue to
parse the source-preserving Python representation.

Converting docstrings to Python documentation comments was also rejected because
it would require more invasive source transformation without providing a benefit
for the proven milestone-1 representation.

## Consequences

Python remains the maintained and filtered source language.  Supported field
translations preserve physical line count, and Doxygen continues to own Python
declaration parsing.  Future syntax support must preserve this separation unless
a superseding ADR is supported by new integration evidence.

## Related Decisions

- ADR-000 requires evidence-oriented capability claims.
- ADR-001 defines which docstrings and fields may be translated.
- ADR-005 requires integration evidence in addition to golden text output.

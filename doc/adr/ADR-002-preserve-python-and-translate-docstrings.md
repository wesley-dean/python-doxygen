# ADR-002: Preserve Python and translate docstrings

Date: 2026-09-11

## Status

Accepted

## Context

The product model preserves Python declarations and changes only structured field
syntax inside recognized docstrings.  This keeps the filtered stream close to
maintained source and preserves line correspondence, but it is valid only if
Doxygen associates an ordinary Python docstring containing translated commands
with the documented Python entity and interprets those translated commands as
Doxygen documentation commands.

The required experiment uses
`tests/python/fixtures/00-doxygen-experiment.py` and the manually translated
candidate in `tests/python/expected/00-doxygen-experiment.py`.

Doxygen's Python handling has an important configuration boundary.  With
`PYTHON_DOCSTRING = YES`, Python docstrings are treated as preformatted text, so
Doxygen special commands inside them are not interpreted structurally.  The
source-preserving translation model therefore requires
`PYTHON_DOCSTRING = NO` for Doxygen-facing integration configurations that expect
translated commands such as `@param`, `@return`, `@exception`, or `@par` to be
parsed as commands.

## Decision Drivers

- Keep Python parsing with Doxygen rather than synthesizing another language.
- Preserve source lines where practical.
- Avoid Doxygen-specific syntax in maintained Python.
- Base the representation on generated Doxygen evidence rather than assumption.
- Verify Doxygen command semantics rather than only the presence of translated
  text in generated output.

## Decision

The project SHALL preserve Python declarations and ordinary triple-double-quoted
docstrings in the filtered stream.  Within docstrings recognized under ADR-001
and later governing recognition decisions, the filter SHALL translate only the
supported structured field lines and leave ordinary prose and surrounding Python
source in place.

Doxygen integration configurations that consume the translated stream and rely on
Doxygen commands inside Python docstrings SHALL set `PYTHON_DOCSTRING = NO`.
Integration tests SHALL exercise that configuration so generated documentation
evidence demonstrates command interpretation rather than mere text preservation.

The original representation experiment executed Doxygen against the manually
translated candidate and verified that generated XML contained the function
prose, parameter description, return description, and exception information.
The subsequent integration job ran Doxygen through the maintained
`doxygen-python.awk` filter and verified the same information in generated XML.
Those checks succeeded on 2026-09-11 in pull request #4 and established that the
source-preserving representation survived the Doxygen pipeline.

A follow-on issue-5 representation experiment on 2026-09-12 exposed that the
integration configuration was still using Doxygen's default
`PYTHON_DOCSTRING = YES`.  That setting preserved the translated command text but
did not provide sufficiently strong evidence that Doxygen interpreted the text as
structured commands.  The integration configuration was corrected to
`PYTHON_DOCSTRING = NO`, and the maintained integration suite subsequently passed
with Doxygen command parsing enabled.  The stronger configuration is therefore
part of the accepted representation contract.

## Alternatives Considered

Requiring Doxygen-specific docstrings in maintained Python was rejected because
it violates the canonical Python documentation standard.  Synthesizing pseudo-C++
was rejected because the experiment demonstrated that Doxygen can continue to
parse the source-preserving Python representation.

Converting docstrings to Python documentation comments was also rejected because
it would require more invasive source transformation without providing a benefit
for the proven source-preserving representation.

Leaving `PYTHON_DOCSTRING = YES` was rejected for integration configurations that
expect translated Doxygen commands because it weakens the generated evidence to
text preservation and does not exercise the intended structured command
semantics.

## Consequences

Python remains the maintained and filtered source language.  Supported field
translations preserve physical line count, and Doxygen continues to own Python
declaration parsing.  Doxygen integrations that rely on translated commands must
use `PYTHON_DOCSTRING = NO`; this configuration requirement is part of the
Doxygen-facing contract and must remain covered by integration tests.  Future
syntax support must preserve this separation unless a superseding ADR is supported
by new integration evidence.

## Related Decisions

- ADR-000 requires evidence-oriented capability claims.
- ADR-001 defines the original docstring and field translation boundary.
- ADR-005 requires integration evidence in addition to golden text output.
- ADR-009 expands standards-conforming docstring recognition without changing the
  source-preserving representation decision.

# Python Documentation Standard Coverage

This matrix compares the canonical Python documentation standard in
`wesley-dean/coding_standards/standards/python/documentation-standard.md` with
the current `python-doxygen` translation boundary.  The canonical standard is
authoritative for maintained Python source.  This document records filter
coverage and implementation work; it does not redefine the standard.

## Coverage states

- **Supported** means focused regression coverage exists and the filter provides
  the documented Doxygen-facing behavior.
- **Partial** means some governed forms work, but standards-conforming cases are
  still outside the supported boundary.
- **Pass-through** means source remains visible without structured Doxygen
  translation.
- **Planned** means issue #5 requires a governed implementation or experiment.
- **Delegated** means the concern intentionally remains with Python-native tools
  rather than the Doxygen filter.

## Coverage matrix

| Standard area | Current behavior | Target / decision | Governance / evidence |
| --- | --- | --- | --- |
| Ordinary triple-double-quoted module docstrings | Supported | Retain | ADR-001, ADR-002 |
| Ordinary class docstrings | Supported | Retain | ADR-001, ADR-002 |
| Ordinary function and method docstrings | Supported | Retain | ADR-001, ADR-002 |
| Raw `r"""..."""` / `R"""..."""` docstrings | Supported | Retain where the standard calls for literal backslashes | ADR-009; focused and Doxygen integration fixtures |
| Other string prefixes | Pass-through | Remain unsupported unless the canonical standard requires them | ADR-009 |
| One-line prose docstrings | Supported in governed positions | Retain deterministic recognition | ADR-009; focused fixtures |
| Multi-line `def` headers | Supported for conventional headers terminating with a suite-opening colon | Retain conservative boundary | ADR-009; focused fixtures |
| Multi-line `async def` headers | Supported for conventional headers terminating with a suite-opening colon | Retain conservative boundary | ADR-009; focused fixtures |
| Multi-line `class` headers | Supported for conventional headers terminating with a suite-opening colon | Retain conservative boundary | ADR-009; focused fixtures |
| Runtime triple-quoted strings after a suite statement | Supported pass-through | Retain non-recognition | ADR-001, ADR-009 |
| `:param name:` | Supported | Retain; adjacent continuation prose remains unchanged | ADR-001, ADR-003; focused continuation fixture |
| `:returns:` | Supported | Retain; adjacent continuation prose remains unchanged | ADR-001, ADR-003; focused continuation fixture |
| `:raises ExceptionType:` | Supported | Retain; adjacent continuation prose remains unchanged | ADR-001, ADR-003; focused continuation fixture |
| `:yields:` | Supported | Translate to a dedicated Doxygen `Yields` paragraph | ADR-003; representation experiment and focused fixture |
| Structured-field continuation prose | Supported for governed fields | Preserve unchanged while Doxygen retains paragraph association | ADR-003; representation experiment and focused fixture |
| `:type name:` for intentionally unannotated interfaces | Pass-through | Experiment and decide whether Doxygen translation adds faithful value | Decision pending |
| `:rtype:` for intentionally unannotated interfaces | Pass-through | Experiment and decide whether Doxygen translation adds faithful value | Decision pending |
| Descriptive prose, notes, warnings, examples | Supported pass-through | Retain visible source; translate only where an explicit representation is governed | ADR-002 |
| Properties | Uses ordinary decorated-function recognition when declaration form is supported | Add focused fixtures and Doxygen evidence; no special parser semantics unless evidence requires them | Tests pending |
| Async functions | Supported for governed single-line and multi-line declarations | Add representative standard-form integration evidence | ADR-009; focused fixtures |
| Generators | Function docstrings and governed `:yields:` translation supported | Add representative scenario coverage | ADR-003; focused fixture |
| Context managers | Function docstrings recognized when declaration form is supported | Add focused fixtures; generator/yield semantics handled separately | Tests pending |
| Decorated functions and methods | Declaration recognition survives preceding decorator lines | Add focused fixtures for representative standard forms; avoid broad decorator inference | ADR-001, ADR-009 |
| Parameter/signature agreement | Delegated | Keep with Python-native tooling such as Pylint | ADR-001, ADR-009 |
| Return / exception inference | Delegated | Do not infer undocumented contracts | ADR-000, ADR-001 |
| Type inference | Delegated | Do not infer types; translate only maintained type documentation if governed | ADR-000, ADR-001 |
| Source-line correspondence | Supported except governed yields expansion | Preserve physical line count except the one-line-per-yields exception in ADR-003 | ADR-002, ADR-003 |
| Ambiguous or unsupported markup | Visible pass-through | Retain conservative pass-through rather than guessing | ADR-000, ADR-001 |

## Implementation order

Issue #5 proceeds in layers so the parser boundary and generated representation
remain independently reviewable:

1. broaden docstring recognition only as governed by ADR-009;
2. add focused fixtures for raw docstrings, deterministic one-line docstrings,
   multiline declarations, and runtime-string non-regression;
3. establish and govern `:yields:` and structured-field continuation behavior by
   Doxygen experiment under ADR-003;
4. run isolated experiments for `:type name:` and `:rtype:` before deciding
   whether translation adds faithful value;
5. add focused semantic fixtures and Doxygen XML assertions for each accepted
   representation;
6. extend the scenario-level program regressions to combine the newly governed
   behavior; and
7. update README capability claims only after source, distribution, and Doxygen
   integration tests demonstrate the resulting contract.

## Non-goals

Full standards conformance does not mean implementing a Python parser in AWK.
The filter remains a documentation-boundary translator.  Signature validation,
semantic type checking, inference of returns or exceptions, decorator semantics,
and other program analysis remain outside the filter unless separately governed
by evidence and an explicit architectural decision.

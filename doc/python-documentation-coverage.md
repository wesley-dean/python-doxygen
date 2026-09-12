# Python Documentation Standard Coverage

This matrix compares the canonical Python documentation standard in
`wesley-dean/coding_standards/standards/python/documentation-standard.md` with
the current `python-doxygen` translation boundary.  The canonical standard is
authoritative for maintained Python source.  This document records filter
coverage and implementation work; it does not redefine the standard.

## Coverage states

- **Supported** means focused regression coverage exists and the filter provides
  the documented Doxygen-facing behavior.
- **Pass-through** means source remains visible without structured Doxygen
  translation.
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
| `:yields:` | Supported | Translate to a dedicated Doxygen `Yields` paragraph | ADR-003; representation experiment, semantic fixture, and Doxygen integration |
| Structured-field continuation prose | Supported for governed fields | Preserve unchanged while Doxygen retains paragraph association | ADR-003; focused and Doxygen integration fixtures |
| `:type name:` for intentionally unannotated interfaces | Supported | Translate to a dedicated `Type of name` paragraph; do not validate whether the field is redundant with annotations | ADR-010; focused and Doxygen integration fixtures |
| `:rtype:` for intentionally unannotated interfaces | Supported | Translate to a dedicated `Return type` paragraph; do not infer or validate signature types | ADR-010; focused and Doxygen integration fixtures |
| Descriptive prose, notes, warnings, examples | Supported pass-through | Retain visible source; translate only where an explicit representation is governed | ADR-002 |
| Properties | Supported through ordinary decorated-function recognition | No special parser semantics | ADR-009; standard-form fixture and Doxygen integration |
| Async functions | Supported for governed single-line and multi-line declarations | Retain | ADR-009; focused, scenario, and standard-form fixtures |
| Generators | Supported with governed `:yields:` translation | Retain | ADR-003; focused, scenario, and standard-form fixtures |
| Context managers | Supported through ordinary decorated-function recognition and governed yield translation | No special decorator inference | ADR-003, ADR-009; standard-form fixture and Doxygen integration |
| Decorated functions and methods | Supported when the underlying declaration form is governed | Retain conservative decorator-agnostic recognition | ADR-001, ADR-009; standard-form fixture and Doxygen integration |
| Parameter/signature agreement | Delegated | Keep with Python-native tooling such as Pylint | ADR-001, ADR-009 |
| Return / exception inference | Delegated | Do not infer undocumented contracts | ADR-000, ADR-001 |
| Type inference and type-field redundancy checks | Delegated | Translate maintained type fields only; do not infer or reconcile types | ADR-000, ADR-010 |
| Source-line correspondence | Supported except governed titled-paragraph expansion | Preserve physical line count except one added line for each translated `:yields:`, `:type`, or `:rtype:` field | ADR-002, ADR-003, ADR-010 |
| Ambiguous or unsupported markup | Visible pass-through | Retain conservative pass-through rather than guessing | ADR-000, ADR-001, ADR-009 |

## Resulting boundary

Issue #5 closes the gap between the milestone-1 filter and the canonical Python
documentation standard without turning the AWK filter into a Python parser or
linter.  Standards-conforming maintained source can use ordinary or raw
docstrings, conventional multi-line declarations, the governed structured fields,
and representative property, async, generator, context-manager, and decorated
function forms without learning a second Doxygen-specific authoring dialect.

The remaining exclusions are intentional boundaries rather than unfinished issue
#5 work.  Unsupported string prefixes and lexically ambiguous source remain
visible.  Signature/documentation agreement, type correctness, redundancy between
annotations and `:type:` / `:rtype:`, decorator semantics, and other program
analysis remain with Python-native tooling.

## Non-goals

Full standards conformance does not mean implementing a Python parser in AWK.
The filter remains a documentation-boundary translator.  Signature validation,
semantic type checking, inference of returns or exceptions, decorator semantics,
and other program analysis remain outside the filter unless separately governed
by evidence and an explicit architectural decision.

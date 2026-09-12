# Python Documentation Standard

The normative Python documentation standard for this repository is maintained at:

`wesley-dean/coding_standards/standards/python/documentation-standard.md`

The canonical file is authoritative.  This repository must not independently
rewrite or weaken that contract.  A later documentation-dependency milestone may
materialize the canonical bytes here through `bashdeps`; until then, contributors
and agents must review the canonical source directly.

The adopted standard establishes Python docstrings as the maintained source of
truth and uses triple-double-quoted docstrings with structured fields including:

```text
:param name: description
:returns: description
:raises ExceptionType: description
:yields: description
```

`python-doxygen` operates only at the documentation-generation boundary.  It
translates the explicitly supported subset into a Doxygen-facing representation
without requiring maintainers to keep a second Doxygen-specific documentation
dialect.

This adoption file is not a substitute for the complete canonical standard.

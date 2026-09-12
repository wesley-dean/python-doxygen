# Python Documentation Standard

This file is synchronized from:

`wesley-dean/coding_standards/standards/python/documentation-standard.md`

The canonical standard is authoritative.  Do not edit this synchronized copy
locally.  Synchronize changes from `coding_standards` instead.

Python docstrings are the maintained source of truth for generated API reference
documentation.  Maintained source uses triple-double-quoted Python docstrings and
Sphinx/reStructuredText structured fields such as:

```text
:param name: description
:returns: description
:raises ExceptionType: description
:yields: description
```

`python-doxygen` operates only at the documentation-generation boundary.  It
translates supported structured fields into a Doxygen-friendly representation
without requiring a second Doxygen-specific source dialect.

For the complete normative requirements, including module, class, function,
method, generator, exception, side-effect, property, asynchronous, and context
manager documentation, consult the canonical file above.

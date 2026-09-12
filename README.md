# python-doxygen

`python-doxygen` is a documentation-led Doxygen input filter for Python.  It
translates Python-native PEP 257/Sphinx docstrings into a candidate
Doxygen-friendly representation while preserving Python as the maintained source
language.

The filter does not require Doxygen-specific Python docstrings, does not replace
Python's parser or linters, and does not infer undocumented API contracts.

## Milestone 1

The current implementation deliberately supports a small subset:

- triple-double-quoted module docstrings;
- triple-double-quoted class docstrings;
- triple-double-quoted function and method docstrings;
- descriptive prose inside recognized docstrings;
- `:param name:` field translation;
- `:returns:` field translation;
- `:raises ExceptionType:` field translation;
- pass-through of Python outside translated docstrings;
- line-count preservation for supported translations;
- warning diagnostics and `--strict`; and
- a portable-AWK implementation intended for `mawk` and GNU awk.

The source-preserving Doxygen representation is still governed by Proposed
ADR-002 until the repository's Doxygen integration experiment passes.  Field
translation is implemented and covered by golden fixtures; successful Doxygen
association and rendering must not be claimed until that experiment is green.

The filter is not a complete Python parser.  Raw or otherwise prefixed docstrings,
arbitrary quote forms, complete reStructuredText parsing, signature validation,
type inference, inferred returns or exceptions, broad decorator semantics, and
complex implicit string concatenation are outside milestone 1.

`:yields:` is deliberately not translated in milestone 1 under ADR-003.

## Usage

Run the maintained filter with an AWK implementation:

```sh
awk -f doxygen-python.awk -- path/to/module.py
```

Enable strict diagnostics with:

```sh
awk -f doxygen-python.awk -- --strict path/to/module.py
```

Normal mode warns and continues when the source can be preserved safely.  Strict
mode emits the same diagnostics and exits non-zero when any diagnostic is
recorded.

## Structured fields

Maintained Python remains Python-native:

```python
def load(path: str) -> str:
    """Load a value from ``path``.

    :param path: Path to load.
    :returns: The loaded value.
    :raises ValueError: The path is invalid.
    """
```

The candidate filtered stream changes those supported field lines to Doxygen
parameter, return, and exception commands while preserving ordinary prose and
Python source.

## Tests and build artifacts

Run the semantic suite against maintained source and generated consumer bytes:

```sh
make test AWK_BIN=mawk
make test AWK_BIN=gawk
```

Build the consumer artifact and checksum with:

```sh
make build
make checksums
```

The generated files are:

```text
dist/doxygen-python.awk
dist/doxygen-python.awk.sha256
```

Build provenance is inserted as comments only so artifact metadata cannot change
AWK execution semantics.

## Documentation and governance

The canonical Python documentation contract is maintained in
`wesley-dean/coding_standards/standards/python/documentation-standard.md`.
`doc/documentation-standard.md` records the repository's adoption point; the
canonical file remains authoritative until dependency synchronization is added.

Before changing parser boundaries, generated representation, portability, or the
artifact contract, review `AGENTS.md`, the documentation standards, all ADRs in
`doc/adr/`, and `doc/decisions.md`.  Accepted ADRs govern the implementation.

## License

This project is licensed under the Creative Commons License 1.0 Universal
License.  See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome.  See [CONTRIBUTING.md](CONTRIBUTING.md) and
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Author

- Wes Dean

# python-doxygen

`python-doxygen` is a documentation-led Doxygen input filter for Python.  It
translates Python-native PEP 257/Sphinx docstrings into a Doxygen-friendly
representation while preserving Python as the maintained source language.

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
- portable operation tested with `mawk` and GNU awk.

ADR-002 records the successful Doxygen experiment: Doxygen parses the
source-preserving Python representation and generated XML contains the translated
function prose, parameter, return, and exception documentation.

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

The filtered stream changes those supported field lines to Doxygen parameter,
return, and exception commands while preserving ordinary prose and Python source.

## Tests and build artifacts

Run the semantic suite against maintained source and generated consumer bytes:

```sh
make test AWK_BIN=mawk
make test AWK_BIN=gawk
```

CI runs both implementations and a Doxygen integration job.  Build the consumer
artifact and checksum with:

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

## Documentation tooling

The repository maintains separate paths for project reference documentation and
for testing the Python filter itself.  `tests/doxygen/Doxyfile` exercises
`doxygen-python.awk` against Python input.  The root `Doxyfile` documents this
project's maintained AWK, Bash, Markdown, and ADR sources.

Reference documentation uses released, SHA-256-pinned `awk-doxygen`,
`bash-doxygen`, and `adrctl` assets declared in `dependencies-docs.txt`.  A pinned
`bashdeps` release synchronizes those assets beneath `vendor/`.

Prepare and verify documentation dependencies with:

```sh
make deps-docs
make deps-docs-check
```

Generate the ADR landing page and project reference documentation with:

```sh
make adr-index
make docs
```

The generated ADR landing page is `doc/adr/README.md`; generated Doxygen output
is under `doc/reference/`.  Those paths and `vendor/` are disposable generated
state and are ignored by Git.  GitHub Pages regenerates the reference site from
maintained source rather than committing generated HTML.

## Releases and downstream dependencies

Semantic-version releases publish the tested consumer artifact and its checksum:

```text
doxygen-python.awk
doxygen-python.awk.sha256
```

These release assets are the dependency interface for downstream repositories.
A downstream project pins a specific `python-doxygen` version in its `bashdeps`
manifest using that version's public release-asset URL and the SHA-256 digest of
the published filter.  During the downstream build, `bashdeps` downloads those
exact public bytes and verifies the digest before use.  Consumption therefore
requires neither version discovery nor GitHub authentication.

The versioning workflow validates maintained source, builds and tests the exact
distribution artifact, generates and verifies its checksum, exercises the
release candidate through Doxygen, and publishes both files as release assets.
A release-artifact canary may independently download the public released files,
verify the checksum, and exercise the Python filter through the same Doxygen
integration fixture.

## Documentation and governance

The canonical Python documentation contract is maintained in
`wesley-dean/coding_standards/standards/python/documentation-standard.md`.
`doc/documentation-standard.md` records the repository's adoption point.

The maintained AWK filter follows the checked-in
`doc/awk-documentation-standard.md`, whose canonical upstream is
`wesley-dean/coding_standards/standards/awk/documentation-standard.md`.

Before changing parser boundaries, generated representation, portability,
documentation publication, or the artifact contract, review `AGENTS.md`, the
documentation standards, all ADRs in `doc/adr/`, and `doc/decisions.md`.
Accepted ADRs govern the implementation.

## License

This project is licensed under the Creative Commons License 1.0 Universal
License.  See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome.  See [CONTRIBUTING.md](CONTRIBUTING.md) and
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Author

- Wes Dean

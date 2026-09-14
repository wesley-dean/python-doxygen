# python-doxygen

`python-doxygen` is a documentation-led Doxygen input filter for Python.  It
translates Python-native PEP 257/Sphinx docstrings into a Doxygen-friendly
representation while preserving Python as the maintained source language.

The filter does not require Doxygen-specific Python docstrings, does not replace
Python's parser or linters, and does not infer undocumented API contracts.

## Supported documentation surface

The current implementation supports the Python documentation forms governed by
the repository's adopted documentation standard, including:

- ordinary triple-double-quoted module, class, function, and method docstrings;
- raw `r"""..."""` and `R"""..."""` docstrings when literal backslashes are
  required;
- deterministic one-line prose docstrings in governed documentation positions;
- conventional multi-line `def`, `async def`, and `class` declaration headers;
- descriptive prose inside recognized docstrings;
- `:param name:` field translation;
- `:returns:` field translation;
- `:raises ExceptionType:` field translation;
- `:yields:` translation to a dedicated Doxygen `Yields` paragraph;
- `:type name:` translation to a dedicated `Type of name` paragraph;
- `:rtype:` translation to a dedicated `Return type` paragraph;
- continuation prose for governed structured fields;
- representative property, async-function, generator, context-manager, and
  decorated-function forms without special decorator inference;
- pass-through of Python outside translated docstrings;
- warning diagnostics and `--strict`; and
- portable operation tested with `mawk` and GNU awk.

Most translations preserve physical line count.  The titled-paragraph
representations for `:yields:`, `:type name:`, and `:rtype:` add one output line
per translated field so Doxygen receives separate paragraph titles and bodies.
ADRs 003 and 010 govern those bounded exceptions.

Doxygen-facing integrations that expect translated commands inside Python
docstrings to be interpreted structurally must set `PYTHON_DOCSTRING = NO`.
The maintained integration configuration and CI suite exercise that contract.

The filter remains intentionally narrower than a Python parser or linter.  It
does not infer types, returns, exceptions, or decorator semantics; validate
signature/documentation agreement; decide whether `:type:` or `:rtype:` is
redundant with annotations; or reinterpret unsupported or lexically ambiguous
source.  Unsupported forms remain visible rather than being assigned speculative
semantics.

See `doc/python-documentation-coverage.md` for the complete supported,
pass-through, and delegated boundary.

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

The filtered stream changes governed field lines to Doxygen commands or titled
paragraphs while preserving ordinary prose and surrounding Python source.

Intentionally unannotated interfaces may also carry maintained type fields when
the adopted Python documentation standard permits them:

```python
def load_unannotated(path):
    """Load a configuration value.

    :param path: Path to read.
    :type path: pathlib.Path
    :returns: Loaded configuration.
    :rtype: Configuration
    """
```

The filter translates those maintained type assertions for Doxygen; it does not
validate whether annotations should have been used instead.

## Tests and build artifacts

Run GNU awk's fatal lint mode against maintained root AWK sources with:

```sh
make check
```

Linting is intentionally separate from semantic testing.  Prepare the pinned
build dependency and run the semantic suite against maintained source and every
generated executable artifact with:

```sh
make deps
make test AWK_BIN=mawk
make test AWK_BIN=gawk
```

The semantic harness emits one TAP-compliant stream for every selected filter.
`make test-source` remains source-only, while `make test-dist` validates the
three generated variants together.

`awk-minifier` is an explicit build dependency pinned in `dependencies.txt` and
materialized beneath `vendor/` by the repository's pinned `bashdeps` bootstrap.
`make deps` may use the network.  `make deps-check` and `make build` consume
prepared dependency state without silently downloading or advancing it.

Build all generated forms and their checksums with:

```sh
make build
make checksums
```

The generated files are:

```text
dist/doxygen-python.dev.awk
dist/doxygen-python.dev.awk.sha256
dist/doxygen-python.awk
dist/doxygen-python.awk.sha256
dist/doxygen-python.min.awk
dist/doxygen-python.min.awk.sha256
```

The development artifact preserves the maintained body, the ordinary artifact
removes full-line comments while retaining the established consumer filename,
and the minified artifact is produced with the pinned `awk-minifier` release.
Build provenance is generated separately and inserted as comments in every
artifact so representation changes cannot erase provenance or add executable AWK
state.

CI runs GNU awk linting, the semantic suite under both supported AWK
implementations, checksum verification for all generated artifacts, and Doxygen
integration against maintained source and all three generated release candidates.

## Documentation tooling

The repository maintains separate paths for project reference documentation and
for testing the Python filter itself.  `tests/doxygen/Doxyfile` exercises
`doxygen-python.awk` against Python input.  The root `Doxyfile` documents this
project's maintained AWK, Bash, Markdown, and ADR sources.

Reference documentation uses released, SHA-256-pinned `awk-doxygen`,
`bash-doxygen`, and `adrctl` assets declared in `dependencies-docs.txt`.  These are
separate from the build dependency in `dependencies.txt`.  A pinned `bashdeps`
release synchronizes both dependency sets beneath `vendor/` through their
respective Make targets.

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

Semantic-version releases publish all three tested executable representations and
their individual checksums:

```text
doxygen-python.dev.awk
doxygen-python.dev.awk.sha256
doxygen-python.awk
doxygen-python.awk.sha256
doxygen-python.min.awk
doxygen-python.min.awk.sha256
```

The ordinary `doxygen-python.awk` asset remains the default compatibility path.
A downstream project may instead select the development or minified form and pin
that exact asset in its `bashdeps` manifest using a specific release version,
public release-asset URL, and SHA-256 digest.  During the downstream build,
`bashdeps` retrieves those exact public bytes and verifies the digest before use.
Consumption therefore requires neither version discovery nor GitHub
authentication.

The versioning workflow validates maintained source, builds and semantically tests
all three generated artifacts, exercises each release candidate through Doxygen,
generates and verifies all three checksums, and publishes all six files as release
assets.  A release-artifact canary may independently download public released
files, verify checksums, and exercise the selected Python filter through the same
Doxygen integration fixture.

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
Accepted ADRs govern the implementation.  ADR-011 governs the development,
ordinary, and minified distribution contract.

## License

This project is licensed under the Creative Commons License 1.0 Universal
License.  See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome.  See [CONTRIBUTING.md](CONTRIBUTING.md) and
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Author

- Wes Dean
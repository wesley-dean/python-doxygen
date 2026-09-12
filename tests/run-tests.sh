#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

AWK_BIN=${AWK_BIN:-awk}
FILTER=${DOXYGEN_PYTHON_FILTER:-"$ROOT_DIR/doxygen-python.awk"}
case "$FILTER" in
    /*) ;;
    *) FILTER="$ROOT_DIR/$FILTER" ;;
esac

CASE_COUNT=0

fail() {
    printf 'not ok - %s\n' "$1" >&2
    exit 1
}

normalize_warnings() {
    sed 's/^.*: warning: //' "$1"
}

expected_line_expansion() {
    grep -Ec '^[[:space:]]*:yields:[[:space:]]*[^[:space:]].*$' "$1" || true
}

for expected in "$ROOT_DIR"/tests/python/expected/*.py; do
    name=${expected##*/}
    input="$ROOT_DIR/tests/python/fixtures/$name"
    actual="$TMP_DIR/$name"
    errors="$TMP_DIR/$name.err"

    test -f "$input" || fail "missing input fixture for $name"
    if ! "$AWK_BIN" -f "$FILTER" -- "$input" >"$actual" 2>"$errors"; then
        fail "output case failed to execute: $name"
    fi
    test ! -s "$errors" || fail "output case emitted a diagnostic: $name"
    diff -u "$expected" "$actual" || fail "output mismatch: $name"

    expected_lines=$(wc -l <"$input" | tr -d ' ')
    expected_lines=$((expected_lines + $(expected_line_expansion "$input")))
    actual_lines=$(wc -l <"$actual" | tr -d ' ')
    test "$actual_lines" -eq "$expected_lines" || fail "unexpected line-count change: $name"

    CASE_COUNT=$((CASE_COUNT + 1))
    printf 'ok - output: %s\n' "$name"
done

for expected in "$ROOT_DIR"/tests/python/programs-expected/*.py; do
    name=${expected##*/}
    input="$ROOT_DIR/tests/python/programs/$name"
    actual="$TMP_DIR/program-$name"
    errors="$TMP_DIR/program-$name.err"

    test -f "$input" || fail "missing program input for $name"
    if ! "$AWK_BIN" -f "$FILTER" -- "$input" >"$actual" 2>"$errors"; then
        fail "program case failed to execute: $name"
    fi
    test ! -s "$errors" || fail "program case emitted a diagnostic: $name"
    diff -u "$expected" "$actual" || fail "program output mismatch: $name"

    expected_lines=$(wc -l <"$input" | tr -d ' ')
    expected_lines=$((expected_lines + $(expected_line_expansion "$input")))
    actual_lines=$(wc -l <"$actual" | tr -d ' ')
    test "$actual_lines" -eq "$expected_lines" || fail "unexpected program line-count change: $name"

    CASE_COUNT=$((CASE_COUNT + 1))
    printf 'ok - program: %s\n' "$name"
done

for expected in "$ROOT_DIR"/tests/python/diagnostics/*.err; do
    name=${expected##*/}
    name=${name%.err}
    input="$ROOT_DIR/tests/python/diagnostics/$name.py"
    warning_err="$TMP_DIR/$name.warning.err"
    strict_err="$TMP_DIR/$name.strict.err"
    normalized="$TMP_DIR/$name.normalized.err"

    test -f "$input" || fail "missing diagnostic input for $name"
    if ! "$AWK_BIN" -f "$FILTER" -- "$input" >"$TMP_DIR/$name.warning.py" 2>"$warning_err"; then
        fail "non-strict diagnostic case exited non-zero: $name"
    fi
    normalize_warnings "$warning_err" >"$normalized"
    diff -u "$expected" "$normalized" || fail "warning mismatch: $name"

    if "$AWK_BIN" -f "$FILTER" -- --strict "$input" >"$TMP_DIR/$name.strict.py" 2>"$strict_err"; then
        fail "strict diagnostic case exited zero: $name"
    fi
    normalize_warnings "$strict_err" >"$normalized"
    diff -u "$expected" "$normalized" || fail "strict warning mismatch: $name"

    CASE_COUNT=$((CASE_COUNT + 1))
    printf 'ok - diagnostic: %s\n' "$name"
done

runtime="$TMP_DIR/08-runtime-triple-string.py"
grep -Fq ':param fake: This is data, not documentation.' "$runtime" || \
    fail 'runtime triple-quoted string was rewritten'
CASE_COUNT=$((CASE_COUNT + 1))
printf '%s\n' 'ok - boundary: runtime triple string preserved'

printf 'ok - %s regression cases passed with %s\n' "$CASE_COUNT" "$AWK_BIN"

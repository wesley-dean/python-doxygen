#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

AWK_BIN=${AWK_BIN:-awk}
TEST_NUMBER=0
FAILURE_COUNT=0

printf '%s\n' 'TAP version 14'

tap_diag_file() {
    while IFS= read -r line || [ -n "$line" ]; do
        printf '# %s\n' "$line"
    done <"$1"
}

tap_ok() {
    TEST_NUMBER=$((TEST_NUMBER + 1))
    printf 'ok %s - %s\n' "$TEST_NUMBER" "$1"
}

tap_not_ok() {
    TEST_NUMBER=$((TEST_NUMBER + 1))
    FAILURE_COUNT=$((FAILURE_COUNT + 1))
    printf 'not ok %s - %s\n' "$TEST_NUMBER" "$1"
    if [ "$#" -gt 1 ] && [ -s "$2" ]; then
        tap_diag_file "$2"
    fi
}

bail_out() {
    printf 'Bail out! %s\n' "$1"
    exit 1
}

normalize_warnings() {
    sed 's/^.*: warning: //' "$1"
}

expected_line_expansion() {
    grep -Ec '^[[:space:]]*:(yields|rtype):[[:space:]]*[^[:space:]].*$|^[[:space:]]*:type[[:space:]]+[^:[:space:]]+:[[:space:]]*[^[:space:]].*$' "$1" || true
}

resolve_filter() {
    case "$1" in
        /*) printf '%s\n' "$1" ;;
        *) printf '%s/%s\n' "$ROOT_DIR" "$1" ;;
    esac
}

run_filter() {
    label=$1
    FILTER=$(resolve_filter "$2")
    FILTER_TMP="$TMP_DIR/$label"
    mkdir -p "$FILTER_TMP"

    [ -f "$FILTER" ] || bail_out "missing filter: $FILTER"

    for expected in "$ROOT_DIR"/tests/python/expected/*.py; do
        name=${expected##*/}
        input="$ROOT_DIR/tests/python/fixtures/$name"
        actual="$FILTER_TMP/$name"
        errors="$FILTER_TMP/$name.err"
        diff_out="$FILTER_TMP/$name.diff"
        description="$label output: $name"

        [ -f "$input" ] || bail_out "missing input fixture for $name"
        if ! "$AWK_BIN" -f "$FILTER" -- "$input" >"$actual" 2>"$errors"; then
            tap_not_ok "$description" "$errors"
            continue
        fi
        if [ -s "$errors" ]; then
            tap_not_ok "$description" "$errors"
            continue
        fi
        if ! diff -u "$expected" "$actual" >"$diff_out"; then
            tap_not_ok "$description" "$diff_out"
            continue
        fi

        expected_lines=$(wc -l <"$input" | tr -d ' ')
        expected_lines=$((expected_lines + $(expected_line_expansion "$input")))
        actual_lines=$(wc -l <"$actual" | tr -d ' ')
        if [ "$actual_lines" -ne "$expected_lines" ]; then
            printf 'expected %s lines, got %s\n' "$expected_lines" "$actual_lines" >"$diff_out"
            tap_not_ok "$description" "$diff_out"
            continue
        fi

        tap_ok "$description"
    done

    for expected in "$ROOT_DIR"/tests/python/programs-expected/*.py; do
        name=${expected##*/}
        input="$ROOT_DIR/tests/python/programs/$name"
        actual="$FILTER_TMP/program-$name"
        errors="$FILTER_TMP/program-$name.err"
        diff_out="$FILTER_TMP/program-$name.diff"
        description="$label program: $name"

        [ -f "$input" ] || bail_out "missing program input for $name"
        if ! "$AWK_BIN" -f "$FILTER" -- "$input" >"$actual" 2>"$errors"; then
            tap_not_ok "$description" "$errors"
            continue
        fi
        if [ -s "$errors" ]; then
            tap_not_ok "$description" "$errors"
            continue
        fi
        if ! diff -u "$expected" "$actual" >"$diff_out"; then
            tap_not_ok "$description" "$diff_out"
            continue
        fi

        expected_lines=$(wc -l <"$input" | tr -d ' ')
        expected_lines=$((expected_lines + $(expected_line_expansion "$input")))
        actual_lines=$(wc -l <"$actual" | tr -d ' ')
        if [ "$actual_lines" -ne "$expected_lines" ]; then
            printf 'expected %s lines, got %s\n' "$expected_lines" "$actual_lines" >"$diff_out"
            tap_not_ok "$description" "$diff_out"
            continue
        fi

        tap_ok "$description"
    done

    for expected in "$ROOT_DIR"/tests/python/diagnostics/*.err; do
        name=${expected##*/}
        name=${name%.err}
        input="$ROOT_DIR/tests/python/diagnostics/$name.py"
        warning_err="$FILTER_TMP/$name.warning.err"
        strict_err="$FILTER_TMP/$name.strict.err"
        normalized="$FILTER_TMP/$name.normalized.err"
        diff_out="$FILTER_TMP/$name.diff"
        description="$label diagnostic: $name"

        [ -f "$input" ] || bail_out "missing diagnostic input for $name"
        if ! "$AWK_BIN" -f "$FILTER" -- "$input" >"$FILTER_TMP/$name.warning.py" 2>"$warning_err"; then
            tap_not_ok "$description" "$warning_err"
            continue
        fi
        normalize_warnings "$warning_err" >"$normalized"
        if ! diff -u "$expected" "$normalized" >"$diff_out"; then
            tap_not_ok "$description" "$diff_out"
            continue
        fi

        if "$AWK_BIN" -f "$FILTER" -- --strict "$input" >"$FILTER_TMP/$name.strict.py" 2>"$strict_err"; then
            printf '%s\n' 'strict diagnostic case exited zero' >"$diff_out"
            tap_not_ok "$description" "$diff_out"
            continue
        fi
        normalize_warnings "$strict_err" >"$normalized"
        if ! diff -u "$expected" "$normalized" >"$diff_out"; then
            tap_not_ok "$description" "$diff_out"
            continue
        fi

        tap_ok "$description"
    done

    malformed_yields="$FILTER_TMP/malformed-yields.py"
    {
        printf '%s\n' 'def values():'
        printf '%s\n' '    """Document values.'
        printf '%s\n' ''
        printf '%s%s\n' '    :yi' 'elds:'
        printf '%s\n' '    """'
        printf '%s\n' '    return None'
    } >"$malformed_yields"
    warning_err="$FILTER_TMP/malformed-yields.warning.err"
    strict_err="$FILTER_TMP/malformed-yields.strict.err"
    normalized="$FILTER_TMP/malformed-yields.normalized.err"
    expected_err="$FILTER_TMP/malformed-yields.expected.err"
    diff_out="$FILTER_TMP/malformed-yields.diff"
    description="$label diagnostic: malformed yields field"
    printf '%s\n' 'malformed :yields field' >"$expected_err"
    if ! "$AWK_BIN" -f "$FILTER" -- "$malformed_yields" >"$FILTER_TMP/malformed-yields.warning.py" 2>"$warning_err"; then
        tap_not_ok "$description" "$warning_err"
    else
        normalize_warnings "$warning_err" >"$normalized"
        if ! diff -u "$expected_err" "$normalized" >"$diff_out"; then
            tap_not_ok "$description" "$diff_out"
        elif "$AWK_BIN" -f "$FILTER" -- --strict "$malformed_yields" >"$FILTER_TMP/malformed-yields.strict.py" 2>"$strict_err"; then
            printf '%s\n' 'strict malformed yields case exited zero' >"$diff_out"
            tap_not_ok "$description" "$diff_out"
        else
            normalize_warnings "$strict_err" >"$normalized"
            if ! diff -u "$expected_err" "$normalized" >"$diff_out"; then
                tap_not_ok "$description" "$diff_out"
            else
                tap_ok "$description"
            fi
        fi
    fi

    for field in type rtype; do
        input="$FILTER_TMP/malformed-$field.py"
        warning_out="$FILTER_TMP/malformed-$field.warning.py"
        warning_err="$FILTER_TMP/malformed-$field.warning.err"
        strict_err="$FILTER_TMP/malformed-$field.strict.err"
        normalized="$FILTER_TMP/malformed-$field.normalized.err"
        expected_err="$FILTER_TMP/malformed-$field.expected.err"
        diff_out="$FILTER_TMP/malformed-$field.diff"
        description="$label diagnostic: malformed $field field"

        {
            printf '%s\n' 'def load(path):'
            printf '%s\n' '    """Document a deliberately unannotated value.'
            printf '%s\n' ''
            if [ "$field" = type ]; then
                printf '%s%s%s\n' '    :' "$field" ' path:'
            else
                printf '%s%s%s\n' '    :' "$field" ':'
            fi
            printf '%s\n' '    """'
            printf '%s\n' '    return path'
        } >"$input"
        printf '%s%s%s\n' 'malformed :' "$field" ' field' >"$expected_err"

        if ! "$AWK_BIN" -f "$FILTER" -- "$input" >"$warning_out" 2>"$warning_err"; then
            tap_not_ok "$description" "$warning_err"
            continue
        fi
        if ! cmp "$input" "$warning_out" >/dev/null; then
            printf '%s\n' "malformed $field source was rewritten" >"$diff_out"
            tap_not_ok "$description" "$diff_out"
            continue
        fi
        normalize_warnings "$warning_err" >"$normalized"
        if ! diff -u "$expected_err" "$normalized" >"$diff_out"; then
            tap_not_ok "$description" "$diff_out"
            continue
        fi

        if "$AWK_BIN" -f "$FILTER" -- --strict "$input" >"$FILTER_TMP/malformed-$field.strict.py" 2>"$strict_err"; then
            printf '%s\n' "strict malformed $field case exited zero" >"$diff_out"
            tap_not_ok "$description" "$diff_out"
            continue
        fi
        normalize_warnings "$strict_err" >"$normalized"
        if ! diff -u "$expected_err" "$normalized" >"$diff_out"; then
            tap_not_ok "$description" "$diff_out"
            continue
        fi

        tap_ok "$description"
    done

    runtime="$FILTER_TMP/08-runtime-triple-string.py"
    description="$label boundary: runtime triple string preserved"
    if [ ! -f "$runtime" ]; then
        printf '%s\n' 'runtime triple-quoted fixture output is missing' >"$FILTER_TMP/runtime.diff"
        tap_not_ok "$description" "$FILTER_TMP/runtime.diff"
    elif ! grep -Fq ':param fake: This is data, not documentation.' "$runtime"; then
        printf '%s\n' 'runtime triple-quoted string was rewritten' >"$FILTER_TMP/runtime.diff"
        tap_not_ok "$description" "$FILTER_TMP/runtime.diff"
    else
        tap_ok "$description"
    fi
}

if [ "$#" -eq 0 ]; then
    run_filter source "${DOXYGEN_PYTHON_FILTER:-doxygen-python.awk}"
else
    for selected in "$@"; do
        case "$selected" in
            *=*)
                label=${selected%%=*}
                filter=${selected#*=}
                ;;
            *)
                label=${selected##*/}
                filter=$selected
                ;;
        esac
        [ -n "$label" ] || bail_out 'filter label must not be empty'
        [ -n "$filter" ] || bail_out 'filter path must not be empty'
        run_filter "$label" "$filter"
    done
fi

printf '1..%s\n' "$TEST_NUMBER"

if [ "$FAILURE_COUNT" -ne 0 ]; then
    exit 1
fi

#!/usr/bin/awk -f
## @file doxygen-python.awk
## @brief Translates supported Python docstring fields for Doxygen.
## @details
## Preserves Python source and rewrites only governed structured fields inside
## conservatively recognized docstrings.  This is an intentionally small
## documentation translator, not a complete Python parser.  See ADR-001 and the
## Proposed ADR-002 before widening recognition or representation behavior.

## @rule initialize_filter
## @brief Initializes parser state and consumes the `--strict` option.
BEGIN {
    strict = 0
    diagnostics = 0
    in_docstring = 0
    module_doc_possible = 1
    pending_suite = 0
    for (i = 1; i < ARGC; i++) {
        if (ARGV[i] == "--strict") {
            strict = 1
            delete ARGV[i]
        } else if (ARGV[i] == "--") {
            delete ARGV[i]
        }
    }
}

## @fn leading_width(line)
## @brief Returns the leading indentation width of a source line.
## @param line Source line to inspect.
## @returns Number of leading space and tab bytes.
function leading_width(line,    s) {
    s = line
    sub(/[^ \t].*$/, "", s)
    return length(s)
}

## @fn warn(message)
## @brief Records and emits one translation diagnostic.
## @param message Stable diagnostic text.
## @returns No meaningful value.
function warn(message) {
    diagnostics++
    printf "%s:%d: warning: %s\n", FILENAME, FNR, message > "/dev/stderr"
}

## @fn is_blank_or_comment(line)
## @brief Tests for input that may precede a suite's first statement.
## @param line Source line to inspect.
## @returns One for blank or comment-only input; zero otherwise.
function is_blank_or_comment(line,    s) {
    s = line
    sub(/^[ \t]*/, "", s)
    return (s == "" || s ~ /^#/)
}

## @fn is_declaration(line)
## @brief Recognizes milestone-1 class and function declaration headers.
## @param line Source line to inspect.
## @returns One for a supported declaration header; zero otherwise.
function is_declaration(line,    s) {
    s = line
    sub(/^[ \t]*/, "", s)
    return (s ~ /^(async[ \t]+)?def[ \t]+[A-Za-z_][A-Za-z0-9_]*[ \t]*\(/ || s ~ /^class[ \t]+[A-Za-z_][A-Za-z0-9_]*/)
}

## @fn starts_docstring(line)
## @brief Tests for an unprefixed triple-double-quoted string start.
## @param line Source line to inspect.
## @returns One when the first non-whitespace bytes open the supported form.
function starts_docstring(line,    s) {
    s = line
    sub(/^[ \t]*/, "", s)
    return (substr(s, 1, 3) == "\"\"\"")
}

## @fn closes_same_line(line)
## @brief Tests whether a recognized docstring closes on its opening line.
## @param line Recognized docstring start line.
## @returns One when a second delimiter occurs on the line; zero otherwise.
function closes_same_line(line,    s, rest) {
    s = line
    sub(/^[ \t]*/, "", s)
    if (substr(s, 1, 3) != "\"\"\"") return 0
    rest = substr(s, 4)
    return (index(rest, "\"\"\"") > 0)
}

## @fn translate_doc_line(line)
## @brief Translates one supported structured field inside a docstring.
## @param line Physical docstring line to inspect.
## @returns Translated text, or original text when no safe translation exists.
function translate_doc_line(line,    indent, body, name, desc, exc) {
    indent = line
    sub(/[^ \t].*$/, "", indent)
    body = substr(line, length(indent) + 1)
    if (body ~ /^:param[ \t]+[^:]+:/) {
        name = body
        sub(/^:param[ \t]+/, "", name)
        desc = name
        sub(/:.*/, "", name)
        sub(/^[^:]*:[ \t]*/, "", desc)
        if (name == "" || name ~ /[ \t]/) { warn("malformed :param field"); return line }
        return indent "@param " name (desc == "" ? "" : " " desc)
    }
    if (body ~ /^:param([ \t]|:|$)/) { warn("malformed :param field"); return line }
    if (body ~ /^:returns:[ \t]*/) {
        desc = body
        sub(/^:returns:[ \t]*/, "", desc)
        if (desc == "") { warn("malformed :returns field"); return line }
        return indent "@return " desc
    }
    if (body ~ /^:returns([ \t]|$)/) { warn("malformed :returns field"); return line }
    if (body ~ /^:raises[ \t]+[^:]+:/) {
        exc = body
        sub(/^:raises[ \t]+/, "", exc)
        desc = exc
        sub(/:.*/, "", exc)
        sub(/^[^:]*:[ \t]*/, "", desc)
        if (exc == "" || exc ~ /[ \t]/) { warn("malformed :raises field"); return line }
        return indent "@exception " exc (desc == "" ? "" : " " desc)
    }
    if (body ~ /^:raises([ \t]|:|$)/) { warn("malformed :raises field"); return line }
    return line
}

## @rule translate_source_record
## @brief Passes source through and translates fields in recognized docstrings.
{
    line = $0
    if (in_docstring) {
        if (index(line, "\"\"\"") > 0) { in_docstring = 0; print line; next }
        print translate_doc_line(line)
        next
    }
    if (pending_suite) {
        if (is_blank_or_comment(line)) { print line; next }
        if (leading_width(line) > pending_indent && starts_docstring(line)) {
            pending_suite = 0
            if (!closes_same_line(line)) in_docstring = 1
            print line
            next
        }
        pending_suite = 0
    }
    if (module_doc_possible) {
        if (is_blank_or_comment(line)) { print line; next }
        if (leading_width(line) == 0 && starts_docstring(line)) {
            module_doc_possible = 0
            if (!closes_same_line(line)) in_docstring = 1
            print line
            next
        }
        if (leading_width(line) == 0) module_doc_possible = 0
    }
    if (is_declaration(line)) {
        pending_suite = 1
        pending_indent = leading_width(line)
    }
    print line
}

## @rule finalize_filter
## @brief Diagnoses unfinished state and enforces strict-mode failure.
END {
    if (in_docstring) warn("unterminated recognized docstring")
    if (strict && diagnostics > 0) exit 1
}

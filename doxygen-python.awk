#!/usr/bin/awk -f
## @file doxygen-python.awk
## @brief Translates supported Python docstring fields for Doxygen.
## @details
## Preserves Python source and rewrites only governed structured fields inside
## conservatively recognized docstrings.  This is an intentionally small
## documentation translator, not a complete Python parser.  See ADR-001,
## ADR-002, ADR-003, ADR-009, and ADR-010 before widening recognition or
## representation behavior.

## @rule initialize_filter
## @brief Initializes parser state and consumes the `--strict` option.
BEGIN {
    strict = 0
    diagnostics = 0
    in_docstring = 0
    in_declaration = 0
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
## @details
## Copies the input into scratch storage before removing everything after the
## leading spaces and tabs.  The caller-supplied value is not modified.
##
## @param line Source line to inspect.
## @local s Scratch copy used while measuring indentation.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns Number of leading space and tab bytes.
function leading_width(line,    s) {
    s = line
    sub(/[^ \t].*$/, "", s)
    return length(s)
}

## @fn warn(message)
## @brief Records and emits one translation diagnostic.
## @details
## Increments the global diagnostic count and writes one location-qualified
## warning for the current input record.
##
## @param message Stable diagnostic text.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Writes one warning containing the current file name and record number.
##
## @par Side Effects
## Increments the global `diagnostics` counter.
##
## @returns No meaningful value; callers use the function for its side effects.
function warn(message) {
    diagnostics++
    printf "%s:%d: warning: %s\n", FILENAME, FNR, message > "/dev/stderr"
}

## @fn is_blank_or_comment(line)
## @brief Tests for input that may precede a suite's first statement.
## @details
## Removes leading horizontal whitespace from a scratch copy and then checks
## whether the remaining input is empty or begins with a comment marker.
##
## @param line Source line to inspect.
## @local s Scratch copy used while testing the source line.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns One for blank or comment-only input; zero otherwise.
function is_blank_or_comment(line,    s) {
    s = line
    sub(/^[ \t]*/, "", s)
    return (s == "" || s ~ /^#/)
}

## @fn is_declaration_start(line)
## @brief Recognizes governed class and function declaration starts.
## @details
## Removes leading horizontal whitespace from a scratch copy and recognizes only
## the conservative declaration-start forms governed by ADR-009.
##
## @param line Source line to inspect.
## @local s Scratch copy used while testing the declaration syntax.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns One for a supported declaration start; zero otherwise.
function is_declaration_start(line,    s) {
    s = line
    sub(/^[ \t]*/, "", s)
    return (s ~ /^(async[ \t]+)?def[ \t]+[A-Za-z_][A-Za-z0-9_]*[ \t]*\(/ || s ~ /^class[ \t]+[A-Za-z_][A-Za-z0-9_]*/)
}

## @fn declaration_header_complete(line)
## @brief Tests whether a declaration header reaches its suite-opening colon.
## @details
## Removes trailing horizontal whitespace and checks for a final colon.  This is
## intentionally narrower than Python lexical parsing and does not interpret
## inline comments, strings, annotations, or balanced delimiters.
##
## @param line Physical declaration-header line to inspect.
## @local s Scratch copy used while testing the line ending.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns One when the last non-whitespace byte is a colon; zero otherwise.
function declaration_header_complete(line,    s) {
    s = line
    sub(/[ \t]+$/, "", s)
    return (s ~ /:$/)
}

## @fn starts_docstring(line)
## @brief Tests for a supported triple-double-quoted docstring start.
## @details
## Removes leading horizontal whitespace and recognizes the ordinary delimiter
## plus the `r` and `R` raw prefixes required by ADR-009.
##
## @param line Source line to inspect.
## @local s Scratch copy used while testing the opening delimiter.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns One when the first non-whitespace bytes open a supported form.
function starts_docstring(line,    s) {
    s = line
    sub(/^[ \t]*/, "", s)
    if (substr(s, 1, 3) == "\"\"\"") return 1
    return ((substr(s, 1, 1) == "r" || substr(s, 1, 1) == "R") && substr(s, 2, 3) == "\"\"\"")
}

## @fn docstring_open_width(line)
## @brief Returns the byte width of a supported docstring opening form.
## @details
## Distinguishes ordinary and raw supported openings after removing leading
## horizontal whitespace.  Unsupported forms return zero.
##
## @param line Source line beginning with a possible docstring opening.
## @local s Scratch copy used while identifying the opening form.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns Three for ordinary, four for raw, or zero for unsupported input.
function docstring_open_width(line,    s) {
    s = line
    sub(/^[ \t]*/, "", s)
    if (substr(s, 1, 3) == "\"\"\"") return 3
    if ((substr(s, 1, 1) == "r" || substr(s, 1, 1) == "R") && substr(s, 2, 3) == "\"\"\"") return 4
    return 0
}

## @fn closes_same_line(line)
## @brief Tests whether a recognized docstring closes on its opening line.
## @details
## Identifies the governed opening width and searches the remainder of the line
## for a second triple-double-quote delimiter.
##
## @param line Recognized docstring start line.
## @local s Scratch copy used while validating the opening delimiter.
## @local width Width of the supported opening form.
## @local rest Source text following the opening delimiter.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written to STDOUT.
## @par STDERR
## Nothing is written to STDERR.
##
## @returns One when a second delimiter occurs on the line; zero otherwise.
function closes_same_line(line,    s, width, rest) {
    s = line
    sub(/^[ \t]*/, "", s)
    width = docstring_open_width(s)
    if (width == 0) return 0
    rest = substr(s, width + 1)
    return (index(rest, "\"\"\"") > 0)
}

## @fn translate_doc_line(line)
## @brief Translates one supported structured field inside a docstring.
## @details
## Preserves indentation, recognizes only governed Sphinx field forms, and
## returns the original line whenever no safe translation exists.  Malformed
## governed fields are diagnosed and left unchanged.  ADR-003 and ADR-010 permit
## titled-paragraph translations to contain one embedded newline so Doxygen
## receives a separate paragraph title and body.
##
## @param line Physical docstring line to inspect.
## @local indent Leading horizontal whitespace preserved in translated output.
## @local body Docstring content after indentation is removed.
## @local name Parameter or type-field name extracted from a structured field.
## @local desc Description or maintained type value extracted from a supported
## field.
## @local exc Exception name extracted from a `:raises` field.
##
## @par STDIN
## Nothing is read directly from STDIN.
## @par STDOUT
## Nothing is written directly to STDOUT.
## @par STDERR
## Malformed governed fields are reported through `warn()`.
##
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
    if (body ~ /^:yields:[ \t]*/) {
        desc = body
        sub(/^:yields:[ \t]*/, "", desc)
        if (desc == "") { warn("malformed :yields field"); return line }
        return indent "@par Yields\n" indent desc
    }
    if (body ~ /^:yields([ \t]|$)/) { warn("malformed :yields field"); return line }
    if (body ~ /^:type[ \t]+[^:]+:/) {
        name = body
        sub(/^:type[ \t]+/, "", name)
        desc = name
        sub(/:.*/, "", name)
        sub(/^[^:]*:[ \t]*/, "", desc)
        if (name == "" || name ~ /[ \t]/ || desc == "") { warn("malformed :type field"); return line }
        return indent "@par Type of " name "\n" indent desc
    }
    if (body ~ /^:type([ \t]|:|$)/) { warn("malformed :type field"); return line }
    if (body ~ /^:rtype:[ \t]*/) {
        desc = body
        sub(/^:rtype:[ \t]*/, "", desc)
        if (desc == "") { warn("malformed :rtype field"); return line }
        return indent "@par Return type\n" indent desc
    }
    if (body ~ /^:rtype([ \t]|$)/) { warn("malformed :rtype field"); return line }
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
    if (in_declaration) {
        if (declaration_header_complete(line)) {
            in_declaration = 0
            pending_suite = 1
            pending_indent = declaration_indent
        }
        print line
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
    if (is_declaration_start(line)) {
        declaration_indent = leading_width(line)
        if (declaration_header_complete(line)) {
            pending_suite = 1
            pending_indent = declaration_indent
        } else {
            in_declaration = 1
        }
    }
    print line
}

## @rule finalize_filter
## @brief Diagnoses unfinished state and enforces strict-mode failure.
END {
    if (in_docstring) warn("unterminated recognized docstring")
    if (strict && diagnostics > 0) exit 1
}

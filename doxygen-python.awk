#!/usr/bin/awk -f

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

function leading_width(line,    s) {
    s = line
    sub(/[^ \t].*$/, "", s)
    return length(s)
}

function warn(message) {
    diagnostics++
    printf "%s:%d: warning: %s\n", FILENAME, FNR, message > "/dev/stderr"
}

function is_blank_or_comment(line,    s) {
    s = line
    sub(/^[ \t]*/, "", s)
    return (s == "" || s ~ /^#/)
}

function is_declaration(line,    s) {
    s = line
    sub(/^[ \t]*/, "", s)
    return (s ~ /^(async[ \t]+)?def[ \t]+[A-Za-z_][A-Za-z0-9_]*[ \t]*\(/ || s ~ /^class[ \t]+[A-Za-z_][A-Za-z0-9_]*/)
}

function starts_docstring(line,    s) {
    s = line
    sub(/^[ \t]*/, "", s)
    return (substr(s, 1, 3) == "\"\"\"")
}

function closes_same_line(line,    s, rest) {
    s = line
    sub(/^[ \t]*/, "", s)
    if (substr(s, 1, 3) != "\"\"\"") return 0
    rest = substr(s, 4)
    return (index(rest, "\"\"\"") > 0)
}

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

END {
    if (in_docstring) warn("unterminated recognized docstring")
    if (strict && diagnostics > 0) exit 1
}

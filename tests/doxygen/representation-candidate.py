def iter_records(path):
    """Yield records from a path.

    @param path Input path whose records are read.  The description continues
        onto a second physical line without starting another Doxygen section.
    @par Yields
        Validated records in source order.  Iteration is lazy and may stop
        before the source is exhausted.
    @exception ValueError The source contains an invalid record.  The exception
        description also continues on another physical line.
    """
    yield from ()


def load_unannotated(path):
    """Load one unannotated value.

    Type information intentionally remains prose in this experiment because the
    representation for Sphinx :type: and :rtype: fields has not been decided.

    @param path Path to read.
    @return Loaded value.
    """
    return path

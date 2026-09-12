def normalize(value: str) -> str:
    """Normalize a supplied value.

    Convert the value into the canonical representation expected by callers.

    @param value Value to normalize.
    @return The canonical normalized value.
    @exception ValueError The supplied value cannot be normalized.
    """
    return value.strip().lower()

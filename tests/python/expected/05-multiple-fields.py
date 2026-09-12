def normalize(value: str) -> str:
    """Normalize a supplied value.

    @param value Value to normalize.
    @return The normalized value.
    @exception ValueError The value cannot be normalized.
    """
    return value.strip().lower()

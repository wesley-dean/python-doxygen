def normalize(value: str) -> str:
    """Normalize a supplied value.

    :param value: Value to normalize.
    :returns: The normalized value.
    :raises ValueError: The value cannot be normalized.
    """
    return value.strip().lower()

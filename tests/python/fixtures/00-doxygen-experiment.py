def normalize(value: str) -> str:
    """Normalize a supplied value.

    Convert the value into the canonical representation expected by callers.

    :param value: Value to normalize.
    :returns: The canonical normalized value.
    :raises ValueError: The supplied value cannot be normalized.
    """
    return value.strip().lower()

def require_value(value: str) -> str:
    """Require a non-empty value.

    :raises ValueError: The supplied value is empty.
    """
    if not value:
        raise ValueError("empty")
    return value

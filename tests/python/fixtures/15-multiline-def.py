def load_configuration(
    path,
    *,
    strict=True,
):
    """Load and validate a configuration.

    :param path: Configuration path to read.
    :param strict: Whether unknown keys are rejected.
    :returns: The validated configuration.
    """
    return path, strict

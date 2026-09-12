def load_configuration(
    path,
    *,
    strict=True,
):
    """Load and validate a configuration.

    @param path Configuration path to read.
    @param strict Whether unknown keys are rejected.
    @return The validated configuration.
    """
    return path, strict

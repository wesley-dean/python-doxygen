class StatusTracker(
    object,
):
    """Track lifecycle status for one operation."""

    def status(self):
        """Return the current lifecycle status."""
        return "ready"


def normalize_windows_path(
    path: str,
) -> str:
    r"""Normalize a Windows path while preserving literal backslashes.

    :param path: Windows path to normalize, such as ``C:\Temp\data``.
    :returns: The normalized Windows path.
    """
    return path

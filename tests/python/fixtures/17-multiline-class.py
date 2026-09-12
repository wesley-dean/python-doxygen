class RepositoryCache(
    MappingMixin,
    object,
):
    """Cache repository metadata for one synchronization run."""

    def clear(self):
        """Discard all cached metadata."""
        return None

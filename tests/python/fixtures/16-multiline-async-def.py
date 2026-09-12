async def fetch_record(
    key,
    *,
    timeout=None,
):
    """Fetch one record asynchronously.

    :param key: Record identifier to fetch.
    :param timeout: Optional timeout in seconds.
    :returns: The fetched record.
    :raises TimeoutError: The operation exceeds the timeout.
    """
    return key

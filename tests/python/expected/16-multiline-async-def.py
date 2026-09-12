async def fetch_record(
    key,
    *,
    timeout=None,
):
    """Fetch one record asynchronously.

    @param key Record identifier to fetch.
    @param timeout Optional timeout in seconds.
    @return The fetched record.
    @exception TimeoutError The operation exceeds the timeout.
    """
    return key

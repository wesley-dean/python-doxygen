"""Async worker examples for longer state-transition coverage."""

import asyncio


async def fetch_record(identifier, retries=3):
    """
    Fetch one record after an asynchronous scheduling point.

    :param identifier: Stable record identifier.
    :param retries: Maximum number of attempts.
    :returns: A dictionary containing the record identifier.
    :raises LookupError: The identifier is empty.
    """
    if not identifier:
        raise LookupError("identifier is required")
    await asyncio.sleep(0)
    return {"id": identifier, "retries": retries}


async def stream_records(records):
    """
    Yield records without assigning return semantics to generator output.

    :param records: Iterable of records to emit.
    :yields: One record at a time.
    """
    for record in records:
        await asyncio.sleep(0)
        yield record


def immediate(value):
    """Return a value without asynchronous work."""
    return value

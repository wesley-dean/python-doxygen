from contextlib import contextmanager


def traced(function):
    """Return the supplied callable unchanged."""
    return function


class Service:
    @property
    def status(self):
        """Return the current service status."""
        return "ready"


@traced
def decorated(value):
    """Return a decorated value.

    @param value Value to return.
    @return The supplied value.
    """
    return value


async def fetch(value):
    """Return a value from an async function.

    @param value Value to return.
    @return The supplied value.
    """
    return value


def values():
    """Yield values from a generator.

    @par Yields
    One generated value.
    """
    yield "value"


@contextmanager
def managed_resource(resource):
    """Yield a resource while its context is active.

    @param resource Resource exposed inside the context.
    @par Yields
    The active resource.
    """
    yield resource

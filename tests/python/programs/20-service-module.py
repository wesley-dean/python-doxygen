"""Normalization service used by the larger regression suite."""

from dataclasses import dataclass


@dataclass
class Normalizer:
    """Normalize user-supplied values before storage."""

    prefix: str = ""

    def normalize(self, value):
        # Comments and blank lines may precede the suite's first statement.

        """
        Normalize one value.

        :param value: Value supplied by the caller.
        :returns: The normalized value with the configured prefix.
        :raises ValueError: The supplied value is missing.
        """
        if value is None:
            raise ValueError("value is required")

        text = str(value).strip()
        payload = """
        :param fake: Runtime payload data must not become documentation.
        :returns: Runtime payload data must remain unchanged.
        """
        if payload and not text:
            return self.prefix
        return self.prefix + text

    def passthrough(self, value):
        result = value
        """
        :param value: This string follows a statement and is runtime source.
        :returns: It must remain unchanged.
        """
        return result


def build_normalizer(prefix):
    """
    Construct a normalizer.

    :param prefix: Prefix applied to normalized values.
    :returns: A configured Normalizer instance.
    """
    return Normalizer(prefix=prefix)

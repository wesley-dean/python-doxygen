"""Boundary-heavy examples for conservative recognition and recovery."""


def undocumented(value):
    transformed = value
    """
    :param value: This is runtime source because another statement came first.
    :returns: This must not be translated.
    """
    return transformed


def raw_documented(value):
    r"""
    Raw docstrings are valid Python but outside milestone-1 support.

    :param value: This field must remain unchanged.
    :returns: This field must also remain unchanged.
    """
    return value


class Processor:
    # A comment does not disqualify the class docstring.

    """Process values while exercising class-suite recognition."""

    @staticmethod
    def convert(value):
        # Decorators belong to the declaration, and comments may follow it.
        """
        Convert one value to text.

        :param value: Value to convert.
        :returns: Text representation of the value.
        """
        return str(value)

    def validate(self, value):
        """
        Validate one value.

        :param value: Value to validate.
        :raises ValueError: The value is empty.
        :returns: The original value after validation.
        """
        if value == "":
            raise ValueError("empty value")
        return value


def final_function(value):
    """
    Confirm parser state recovers after unsupported and runtime strings.

    :param value: Final value in the file.
    :returns: The unchanged final value.
    """
    return value

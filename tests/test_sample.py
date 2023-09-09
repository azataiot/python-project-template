# Filename: test_sample.py


def add(a, b):
    return a + b


def subtract(a, b):
    return a - b


def multiply(a, b):
    return a * b


def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero!")
    return a / b


# Test cases
def test_add():
    assert add(1, 2) == 3
    assert add(-1, 1) == 0
    assert add(-1, -1) == -2


def test_subtract():
    assert subtract(3, 2) == 1
    assert subtract(2, 3) == -1
    assert subtract(3, 3) == 0


def test_multiply():
    assert multiply(2, 3) == 6
    assert multiply(-2, 3) == -6
    assert multiply(0, 3) == 0


def test_divide():
    assert divide(6, 2) == 3
    assert divide(6, -2) == -3
    assert divide(0, 1) == 0

    # Test division by zero
    try:
        divide(1, 0)
    except ValueError as e:
        assert str(e) == "Cannot divide by zero!"

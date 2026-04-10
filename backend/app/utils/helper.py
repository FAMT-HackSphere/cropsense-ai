def validate_npk(n, p, k):\n    if any(val < 0 for val in [n, p, k]):\n        return False\n    return True\n

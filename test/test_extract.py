from src.extract import lambda_handler


def test_extract_func_full_json_return():
    test_func = lambda_handler({}, 1)
    assert "date" in test_func
    assert "eur" in test_func

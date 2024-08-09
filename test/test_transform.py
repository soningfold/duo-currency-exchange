from src.transform import lambda_handler as transform
from src.extract import lambda_handler as extract


def test_transform_returns_correct_format_dict():
    required_data = extract({}, 1)
    test_func = transform(required_data, 1)
    assert "eur" in test_func
    assert "rate" in test_func["eur"]
    assert "reverse_rate" in test_func["eur"]


def test_reverse_rate_rounded_six_dec_places():
    required_data = extract({}, 1)
    test_func = transform(required_data, 1)
    assert test_func["eur"]["reverse_rate"] == round(
        test_func["eur"]["reverse_rate"], 6
    )

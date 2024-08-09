from src.load import lambda_handler as load
import boto3
from moto import mock_aws
import pytest
import os
from datetime import datetime
import json


# @pytest.fixture
# def aws_creds():
#     os.environ["AWS_ACCESS_KEY_ID"] = 'test'
#     os.environ["AWS_SECRET_ACCESS_KEY"] = 'test'
#     os.environ["AWS_SECURITY_TOKEN"] = 'test'
#     os.environ["AWS_SESSION_TOKEN"] = 'test'
#     os.environ["AWS_DEFAULT_REGION"] = 'eu-west-2'


# @pytest.fixture
# def s3_client(aws_creds):
#     with mock_aws():
#         client = boto3.client('s3')
#         client.create_bucket(
#             Bucket ="test-bucket",
#             CreateBucketConfiguration={
#                 "LocationConstraint": "eu-west-2"
#             }
#         )
#         yield client


def test_load_function():
    s3 = boto3.client("s3")
    input_dict = {"eur": {"rate": 1.09185582, "reverse_rate": 0.91587184}}
    test_func = load(input_dict, 1)
    date_time = datetime.now()
    response = s3.get_object(
        Bucket="nc-de-currency-data-20240805124549008400000003",
        Key=f"{date_time.year}/{date_time.month}/{date_time.day}/{date_time.hour}:{date_time.minute}:{date_time.second}.json",
    )
    response_body = response["Body"].read()
    decoded_dict = json.loads(response_body.decode('utf-8'))

    assert test_func == {"result": "Success"}
    assert decoded_dict == input_dict

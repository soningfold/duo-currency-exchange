import boto3
from datetime import datetime
import json


def lambda_handler(event, context):
    """Writes the data to a date-encoded S3 folder.

    The folder structure should make it easy to locate rates from a given date and time.

    Args:
        event: dictionary in the same format as the output from the transform function
        context: supplied by AWS

    Returns:
        dictionary, either {'result': 'Success'} if successful or {'result': 'Failure'} otherwise
    """
    currency_exchange_data = json.dumps(event)

    s3 = boto3.client("s3")
    date_time = datetime.now()
    try:
        s3.put_object(
            Bucket="nc-de-currency-data-20240805124549008400000003",
            Key=f"{date_time.year}/{date_time.month}/{date_time.day}/{date_time.hour}:{date_time.minute}:{date_time.second}.json",
            Body=currency_exchange_data,
        )
        return {"result": "Success"}
    except:
        return {"result": "Failure"}

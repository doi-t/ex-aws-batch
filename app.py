import json
import sys
from typing import Dict

import boto3
import requests


def send_notification_to_slack(s3_bucket: str, s3_object_key: str,
                               slack_channel: str) -> Dict:
    s3 = boto3.resource('s3')
    obj = s3.Object(s3_bucket, s3_object_key)
    response = obj.get()
    contents = json.loads(response['Body'].read())
    slack_webhook_url = contents['webhook_url']

    payload = {
        "channel":
        slack_channel,
        "username":
        "AWS Batch",
        "text":
        "This is posted to #test and comes from a submitted AWS Batch Job.",
        "icon_emoji":
        ":tada:"
    }
    requests.post(slack_webhook_url, json=payload)

    return payload


if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)

    if (argc != 4):
        print(
            "Usage: $ python {argvs[0]} s3_bucket s3_object_key slack_channel")
        sys.exit(1)

    s3_bucket = argvs[1]
    s3_object_key = argvs[2]
    slack_channel = argvs[3]

    send_notification_to_slack(s3_bucket, s3_object_key, slack_channel)

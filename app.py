import gzip
import json
import sys
from typing import Dict

import boto3
import requests


def send_notification_to_slack(s3_bucket: str, slack_s3_object_key: str,
                               slack_channel: str,
                               log_s3_object_key: str) -> Dict:
    s3 = boto3.resource('s3')

    # load a gz file that comes from CloudWatch Logs on memory
    log_obj = s3.Object(s3_bucket, log_s3_object_key)
    log_response = log_obj.get()  # expect gz file from s3
    data = gzip.GzipFile(fileobj=log_response['Body']).read().decode(
        'utf-8').split('\n')

    for line in data:
        if line:
            timestamp, log = line.split(" ", 1)
            print(f'timestamp:{line}, log:{log}')

    slack_obj = s3.Object(s3_bucket, slack_s3_object_key)
    response = slack_obj.get()
    contents = json.loads(response['Body'].read())
    slack_webhook_url = contents['webhook_url']

    payload = {
        "channel":
        slack_channel,
        "username":
        "AWS Batch",
        "text":
        f"This is posted to {slack_channel} and comes from a submitted AWS Batch Job.",
        "icon_emoji":
        ":tada:"
    }
    requests.post(slack_webhook_url, json=payload)

    return payload


if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)

    if (argc != 5):
        print(
            "Usage: $ python {argvs[0]} s3_bucket s3_object_key slack_channel")
        sys.exit(1)

    s3_bucket = argvs[1]
    slack_s3_object_key = argvs[2]
    slack_channel = argvs[3]
    log_s3_object_key = argvs[4]

    send_notification_to_slack(s3_bucket, slack_s3_object_key, slack_channel,
                               log_s3_object_key)

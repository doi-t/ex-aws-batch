#!/bin/bash
set -e
[ $# -ne 3 ] && echo "$0 [slack_channel] [slack_message] [path/to/your/zip/file/on/s3]" && exit 1
SLACK_CHANNEL=$1
SLACK_MESSAGE=$2
TARGET_OBJECT_KEY=$3

LOCAL_IMAGE_NAME="local_ex_aws_batch_app"
S3_BUCKET="ex-aws-batch"
S3_SLACK_OBJECT_KEY="slack.json"
docker build --tag $LOCAL_IMAGE_NAME .
docker run \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  $LOCAL_IMAGE_NAME \
  python app.py ${S3_BUCKET} ${S3_SLACK_OBJECT_KEY} ${SLACK_CHANNEL} ${SLACK_MESSAGE} ${TARGET_OBJECT_KEY}

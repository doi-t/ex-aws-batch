#!/bin/bash
set -e
[ $# -ne 4 ] && echo "$0 [slack_channel] [slack_message] [path/to/your/zip/file/on/s3] [batch_job_name]" && exit 1
SLACK_CHANNEL=$1
SLACK_MESSAGE=$2
TARGET_OBJECT_KEY=$3
BATCH_JOB_NAME=$4

S3_BUCKET="ex-aws-batch"
S3_SLACK_OBJECT_KEY="slack.json"
SLACK_CHANNEL="#test"

BATCH_JOB_QUEUE_NAME="ex-aws-batch"
BATCH_JOB_DEFINITION_NAME="ex-aws-batch"

BATCH_JOB_DEFINITION_ARN=$( aws batch describe-job-definitions \
  --job-definition-name ${BATCH_JOB_DEFINITION_NAME} \
  --status ACTIVE \
  | jq -r '.jobDefinitions | max_by(.revision).jobDefinitionArn' \
) && echo ${BATCH_JOB_DEFINITION_ARN}

aws batch submit-job \
  --job-name ${BATCH_JOB_NAME} \
  --job-queue `aws batch describe-job-queues --job-queues $BATCH_JOB_QUEUE_NAME | jq ".jobQueues[].jobQueueArn" -r` \
  --job-definition $BATCH_JOB_DEFINITION_ARN \
  --container-overrides command="python","app.py","${S3_BUCKET}","${S3_SLACK_OBJECT_KEY}","${SLACK_CHANNEL}","${SLACK_MESSAGE}","${TARGET_OBJECT_KEY}"

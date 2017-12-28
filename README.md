# Example of AWS Batch

Try to do something on AWS Batch.

- [x] [Getting Start with AWS Batch](https://gist.github.com/doi-t/01e5241c9595e7b8e3540f0125bd4519)
- [x] Run a Python script on AWS Batch
- [x] Send a slack notification from the AWS Batch Job
- [x] Get [exported logs from S3](https://github.com/doi-t/aws-lambda-cloudwatch-logs-exporter) in the AWS Batch Job
- [x] Manage AWS Batch related resources with terraform
- [ ] Try [AWS Batch Event Stream for CloudWatch Events](https://docs.aws.amazon.com/batch/latest/userguide/cloudwatch_event_stream.html)
- [ ] Submit a job from AWS Lambda
- etc...

## Create AWS Batch Resources
```shell
$ cd tf/
$ terraform init -backend=true \
  -backend-config="bucket=[your_bucket_name]" \
  -backend-config="key=ex-aws-batch/terraform.tfstate" \
  -backend-config="region=[your_region_name]"
$ terraform plan
$ terraform apply
$ aws batch describe-compute-environments
$ aws batch describe-job-queues
$ aws batch describe-job-definitions
```

### Prepare Slack incoming webhook url
```shell
$ cat slack.json
{
    "webhook_url": "[your_slack_incoming_webhook_url]"
}
$ aws s3 cp slack.json s3://ex-aws-batch/slack.json --sse
```

### Push Docker Image to ECR
```shell
$ ./push_image_to_ecr.sh
```

## Test on Local
```shell
$ export ECR_REPO_NAME=ex-aws-batch
$ export S3_BUCKET=ex-aws-batch
$ export S3_SLACK_OBJECT_KEY=slack.json
$ export SLACK_CHANNEL="#test"
$ export TARGET_OBJECT_KEY="path/to/your/zip/file/on/s3"
$ docker run \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  `aws ecr describe-repositories --repository-names $ECR_REPO_NAME | jq ".repositories[].repositoryUri" -r` \
  python app.py ${S3_BUCKET} ${S3_SLACK_OBJECT_KEY} ${SLACK_CHANNEL} ${TARGET_OBJECT_KEY}
  ```

## Submit a Job to AWS Batch

> Environment variables must not start with AWS_BATCH; this naming convention is reserved for variables that are set by the AWS Batch service.
> Ref. https://docs.aws.amazon.com/batch/latest/userguide/submit_job.html

```shell
$ export S3_BUCKET=ex-aws-batch \
  export S3_SLACK_OBJECT_KEY=slack.json \
  export SLACK_CHANNEL="#test" \
  export TARGET_OBJECT_KEY="path/to/your/zip/file/on/s3" \
  export BATCH_JOB_QUEUE_NAME=ex-aws-batch \
  export BATCH_JOB_DEFINITION_NAME=ex-aws-batch \
  export BATCH_JOB_DEFINITION_ARN=$( aws batch describe-job-definitions \
  --job-definition-name ${BATCH_JOB_DEFINITION_NAME} \
  --status ACTIVE \
  | jq -r '.jobDefinitions | max_by(.revision).jobDefinitionArn' \
) && echo ${BATCH_JOB_DEFINITION_ARN}
$ aws batch submit-job \
  --job-name this-is-test-job \
  --job-queue `aws batch describe-job-queues --job-queues $BATCH_JOB_QUEUE_NAME | jq ".jobQueues[].jobQueueArn" -r` \
  --job-definition $BATCH_JOB_DEFINITION_ARN \
  --container-overrides command="python","app.py","${S3_BUCKET}","${S3_SLACK_OBJECT_KEY}","${SLACK_CHANNEL}","${TARGET_OBJECT_KEY}"
```
Ref. https://qiita.com/pottava/items/4151fcb9b14c51f50e9c

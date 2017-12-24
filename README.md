# Example of AWS Batch

Try to do something on AWS Batch.

- [x] [Getting Start with AWS Batch](https://gist.github.com/doi-t/01e5241c9595e7b8e3540f0125bd4519)
- [x] Run a Python script on AWS Batch
- [x] Access S3 from an AWS Batch Job
- [x] Send a slack notification from an AWS Batch Job
- [ ] Try [AWS Batch Event Stream for CloudWatch Events](https://docs.aws.amazon.com/batch/latest/userguide/cloudwatch_event_stream.html)
- [ ] Submit a job from AWS Lambda
- [ ] Manage AWS Batch related resources with terraform
- etc...

## Create AWS Batch Resources
```shell
$ aws batch create-compute-environment --cli-input-json file://batch/compute-environments.json
$ aws batch describe-compute-environments
$ aws batch create-job-queue --cli-input-json file://batch/job-queue.json
$ aws batch describe-job-queues
$ aws batch register-job-definition --cli-input-json file://batch/job-definition.json
$ aws batch describe-job-definitions
```


### Push Docker Image to ECR
```shell
$ cat slack.json
{
    "webhook_url": "[slack_incoming_webhook_url]"
}
$ aws s3 cp slack.json s3://[s3 bucket name]/slack.json --sse
$ export ECR_REPO_NAME=ex-aws-batch
$ aws ecr create-repository --repository-name $ECR_REPO_NAME
$ export ECR_REPO=`aws ecr describe-repositories --repository-names $ECR_REPO_NAME | jq ".repositories[].repositoryUri" -r`
$ docker build --tag $ECR_REPO .
$ docker images
$ aws ecr get-login --no-include-email
$ docker push $ECR_REPO
$ aws ecr list-images --repository-name $ECR_REPO_NAME
```

## Submit a Job to AWS Batch
```shell
$ export BATCH_JOB_QUEUE_NAME=do-something-in-python
$ export BATCH_JOB_DEFINITION_NAME=python-s3-slack
$ aws batch submit-job \
  --job-name send-a-slack-notification \
  --job-queue `aws batch describe-job-queues --job-queues $BATCH_JOB_QUEUE_NAME | jq ".jobQueues[].jobQueueArn" -r` \
  --job-definition `aws batch describe-job-definitions --job-definition-name $BATCH_JOB_DEFINITION_NAME --max-results 1 | jq ".jobDefinitions[].jobDefinitionArn" -r`
```

## Test on Local
```shell
$ docker run \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  `aws ecr describe-repositories --repository-names $ECR_REPO_NAME | jq ".repositories[].repositoryUri" -r` \
  "python" "app.py" "[s3_bucket_name]" "slack.json" "[#slack_channel_name]"
```

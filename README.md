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
$ ./test_on_local.sh "#test" "Test on local" "path/to/your/zip/file/on/s3"
```

## Submit a Job to AWS Batch

> Environment variables must not start with AWS_BATCH; this naming convention is reserved for variables that are set by the AWS Batch service.
> Ref. https://docs.aws.amazon.com/batch/latest/userguide/submit_job.html

```shell
$ ./submit_job.sh "#test" "Test on AWS Batch" "path/to/your/zip/file/on/s3" "Batch Job Name"
```

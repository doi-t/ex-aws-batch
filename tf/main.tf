provider "aws" {
  version = "~> 1.6.0"
  region  = "${var.region}"
}

data "aws_ecr_repository" "ex_aws_batch" {
  name = "${var.resource_name}"
}

resource "aws_batch_compute_environment" "ex_aws_batch" {
  compute_environment_name = "${var.resource_name}"

  compute_resources {
    instance_role = "${aws_iam_instance_profile.ecs_instance_role.arn}"

    instance_type = [
      "m3.medium",
    ]

    max_vcpus = 1
    min_vcpus = 0

    security_group_ids = [
      "${module.sg.this_security_group_id}",
    ]

    subnets = [
      "${module.vpc.public_subnets[0]}",
    ]

    type = "EC2"
  }

  service_role = "${aws_iam_role.aws_batch.arn}"
  type         = "MANAGED"
  state        = "ENABLED"

  tags = {
    Name = "${var.resource_name}"
  }
}

resource "aws_batch_job_queue" "ex_aws_batch" {
  name                 = "${var.resource_name}"
  state                = "ENABLED"
  priority             = 1
  compute_environments = ["${aws_batch_compute_environment.ex_aws_batch.arn}"]
}

resource "aws_batch_job_definition" "ex_aws_batch" {
  name = "${var.resource_name}"
  type = "container"

  retry_strategy {
    attempts = 1
  }

  container_properties = <<CONTAINER_PROPERTIES
{
  "image": "${data.aws_ecr_repository.ex_aws_batch.repository_url}",
  "vcpus": 1,
  "memory": 500,
  "command": [],
  "jobRoleArn": "",
  "volumes": [],
  "environment": [],
  "mountPoints": [],
  "readonlyRootFilesystem": true,
  "privileged": true,
  "ulimits": [],
  "user": ""
}
CONTAINER_PROPERTIES
}

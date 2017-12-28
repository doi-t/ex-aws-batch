module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 1.6.0"

  name        = "${var.resource_name}"
  description = "Security group for EC2 instances launched by AWS Batch"
  vpc_id      = "${module.vpc.vpc_id}"

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Name = "${var.resource_name}"
  }
}

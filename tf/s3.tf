resource "aws_s3_bucket" "aws_batch" {
  bucket = "${var.s3_bucket_name}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Action": "s3:GetBucketAcl",
          "Effect": "Allow",
          "Resource": "arn:aws:s3:::${var.s3_bucket_name}",
          "Principal": { "Service": "logs.${var.region}.amazonaws.com" }
      },
      {
          "Action": "s3:PutObject" ,
          "Effect": "Allow",
          "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*",
          "Condition": { "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control" } },
          "Principal": { "Service": "logs.${var.region}.amazonaws.com" }
      }
    ]
}
EOF

  tags = {
    Name = "${var.resource_name}"
  }
}

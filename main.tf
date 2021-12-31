#####
# Firehose configuration
#####

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  # acl    = "private"
  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = false
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_master_key_id
        sse_algorithm     = var.sse_algorithm
      }
    }
  }
}

resource "aws_iam_role" "firehose" {
  name               = var.iam_firehose_role
  path               = "/service-role/"
  assume_role_policy = <<EOF
  {
     "Version": "2012-10-17",
     "Statement": [
        {
           "Action": "sts:AssumeRole",
           "Principal": {
              "Service": "firehose.amazonaws.com"
           },
           "Effect": "Allow",
           "Condition": {"StringEquals": {"sts:ExternalId": "${var.externalid}"}},
           "Sid": ""
        }
     ]
  }
EOF
}

#commented out for now
#resource "aws_iam_role_policy" "policy" {
# name = ""
#role = "arn:aws:iam::"
#policy_arn = "arn:aws:iam::"
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "",
#             "Effect": "Allow",
#             "Action": [
#                 "glue:GetTable",
#                 "glue:GetTableVersion",
#                 "glue:GetTableVersions"
#             ],
#             "Resource": [
#                 "arn:aws:",
#                 "arn:aws:",
#                 "arn:aws:"
#             ]
#         },
#         {
#             "Sid": "",
#             "Effect": "Allow",
#             "Action": [
#                 "s3:AbortMultipartUpload",
#                 "s3:GetBucketLocation",
#                 "s3:GetObject",
#                 "s3:ListBucket",
#                 "s3:ListBucketMultipartUploads",
#                 "s3:PutObject"
#             ],
#             "Resource": [
#                 "arn:aws:s3",
#                 "arn:aws:s3"
#             ]
#         },
#         {
#             "Sid": "",
#             "Effect": "Allow",
#             "Action": [
#                 "lambda:InvokeFunction",
#                 "lambda:GetFunctionConfiguration"
#             ],
#             "Resource": "arn:aws:lambda:%"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "kms:GenerateDataKey",
#                 "kms:Decrypt"
#             ],
#             "Resource": [
#                 "arn:aws:kms:%"
#             ],
#             "Condition": {
#                 "StringEquals": {
#                     "kms:ViaService": "s3.us-west-2.amazonaws.com"
#                 },
#                 "StringLike": {
#                     "kms:EncryptionContext:aws:s3:arn": [
#                         "arn:aws:s3:::"
#                     ]
#                 }
#             }
#         },
#         {
#             "Sid": "",
#             "Effect": "Allow",
#             "Action": [
#                 "logs:PutLogEvents"
#             ],
#             "Resource": [
#                 "arn:aws:"
#             ]
#         },
#         {
#             "Sid": "",
#             "Effect": "Allow",
#             "Action": [
#                 "kinesis:DescribeStream",
#                 "kinesis:GetShardIterator",
#                 "kinesis:GetRecords",
#                 "kinesis:ListShards"
#             ],
#             "Resource": "arn:"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "kms:Decrypt"
#             ],
#             "Resource": [
#                 "arn:aws:kms:"
#             ],
#             "Condition": {
#                 "StringEquals": {
#                     "kms:ViaService": "kinesis.us-west-2.amazonaws.com"
#                 },
#                 "StringLike": {
#                     "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:"
#                 }
#             }
#         }
#     ]
# }
# EOF
#}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = var.iam_firehose_role
  policy_arn = var.iam_role_policy_arn
}

resource "aws_kinesis_firehose_delivery_stream" "test_stream" {
  name        = var.kinesis_firehose_delivery_stream_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = var.iam_role_arn
    bucket_arn         = aws_s3_bucket.bucket.arn
    buffer_interval    = "300"
    buffer_size        = "5"
    compression_format = "UNCOMPRESSED"
    s3_backup_mode     = "Disabled"

  }
  tags = {
    "waf" = var.tag
  }
  tags_all = {
    "waf" = "var.tag"
  }
  #cloudwatch_logging_options {
  #enabled         = true
  #log_group_name  = "/aws/kinesisfirehose/aws_kinesis_firehose_delivery_stream._stream."
  #log_stream_name = "S3Delivery"
  #}
  #processing_configuration {
  # enabled = false
  #}
  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }
}

#####
# Web Application Firewall configuration
#####
module "wafv2" {
  source                       = "umotif-public/waf-webaclv2/aws"
  version                      = "3.3.0"
  name_prefix                  = var.name_prefix
  alb_arn                      = var.alb_arn
  description                  = var.description
  create_alb_association       = true
  create_logging_configuration = true
  log_destination_configs      = [aws_kinesis_firehose_delivery_stream.test_stream.arn]

  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = var.visibility_metric_name
    sampled_requests_enabled   = true
  }

  rules = [
    {
      name     = var.rule_name
      priority = "0"

      override_action = var.rule_override_action


      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = var.rule_name
        sampled_requests_enabled   = true
      }

      managed_rule_group_statement = {
        name          = "all_rules"
        vendor_name   = "Fortinet"
        excluded_rule = var.excluded_rule
      }
    }
  ]
}

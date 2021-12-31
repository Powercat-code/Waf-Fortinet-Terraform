variable "region" {
  type        = string
  description = "the region where resources should be deployed"
}

variable "profile" {
  type        = string
  description = "profile used to deploy the resources"
}

variable "externalid" {
  type        = string
  description = "external id for iam"
}
variable "tag" {
  type        = string
  description = "profile used to deploy the resources"
  default     = ""
}

variable "bucket_name" {
  description = "S3 bucket name."
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "A prefix used for naming resources."
  type        = string
  default     = ""
}

variable "kms_master_key_id" {
  description = "Bucket KMS key ID."
  type        = string
  default     = ""
}

variable "iam_firehose_role" {
  description = "IAM firehose role ID."
  type        = string
  default     = ""
}

variable "iam_role_policy_name" {
  description = "IAM firehose role policy."
  type        = string
  default     = ""
}

variable "iam_role_policy_arn" {
  description = "IAM firehose role policy arn."
  type        = string
  default     = ""
}

variable "kinesis_firehose_delivery_stream_name" {
  description = "IAM firehose stream name."
  type        = string
  default     = ""
}

variable "iam_role_arn" {
  description = "IAM firehose stream name."
  type        = string
  default     = ""
}

variable "alb_arn" {
  description = "IAM firehose stream name."
  type        = string
  default     = ""
}

variable "description" {
  description = "IAM firehose stream name."
  type        = string
  default     = ""
}

variable "visibility_metric_name" {
  description = "IAM firehose stream name."
  type        = string
  default     = ""
}

variable "rule_name" {
  description = "IAM firehose stream name."
  type        = string
  default     = ""
}

variable "excluded_rule" {
  description = "List of WAF rules."
  type        = any
  default     = []
}

variable "rule_override_action" {
  description = "Rule override."
  type        = string
  default     = ""
}

variable "sse_algorithm" {
  description = "S3 encryption"
  type        = string
  default     = ""
}
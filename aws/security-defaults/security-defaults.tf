variable "default_security_deny_all_traffic_on_aws_regions" {
  type        = list(string)
  description = "List of the AWS regionsn to apply security groups into"
  default     = ["ap-northeast-1", "ap-northeast-2", "ap-south-1", "ap-southeast-1", "ap-souteast-2", "ca-central-1", "eu-central-1", "eu-north-1", "eu-west-1", "eu-west-2", "eu-west-3", "sa-east-1", "us-east-2", "us-west-1", "us-west-2"]
}

variable "default_aws_security_group_vpc_ids" {
  type = list(object({
    vpc_id                = string
  }))

  description = "List of vpc_ids from default security groups with region"
  default     = []
}

resource "aws_default_security_group" "deny_all_traffic" {
  # vpc_id      = data.aws_vpc.default.id

  # dynamic "vpc_id" {
  #   for_each = var.default_aws_security_group_vpc_ids
  #   content {
  #     vpc_id   = default_aws_security_group_vpc_ids.value.vpc_id
  #   }
  # }
}
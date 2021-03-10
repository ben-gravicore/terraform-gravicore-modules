variable "default_security_deny_all_traffic_on_aws_regions" {
  type        = list(string)
  description = "List of the AWS regionsn to apply security groups into"
  default     = ["ap-northeast-1", "ap-northeast-2", "ap-south-1", "ap-southeast-1", "ap-souteast-2", "ca-central-1", "eu-central-1", "eu-north-1", "eu-west-1", "eu-west-2", "eu-west-3", "sa-east-1", "us-east-2", "us-west-1", "us-west-2"]
}

variable "default_security_deny_all_traffic" {
  type        = bool
  description = "Update the rules for the default security groups to deny all traffic by default?"
  default     = true
}

data "aws_vpc" "default" {
  default     = true
}

resource "aws_default_security_group" "deny_all_traffic" {
  vpc_id      = data.aws_vpc.default.id
}

data "aws_security_groups" "default_security_groups" {
  filter {
    name   = "group-name"
    values = ["*default*"]
  }
}
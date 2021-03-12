variable "default_aws_security_group_vpc_id" {
  type        = string
  default     = ""
  description = "vpc_id of default security group"
}

resource "aws_default_security_group" "default" {
  vpc_id      = var.default_aws_security_group_vpc_id
}
variable "default_security_deny_all_traffic" {
  type        = bool
  description = "Update the rules for the default security groups to deny all traffic by default?"
  default     = true
}

data "aws_security_groups" "defaults" {
  filter {
    name   = "group-name"
    values = ["*nodes*"]
  }
}
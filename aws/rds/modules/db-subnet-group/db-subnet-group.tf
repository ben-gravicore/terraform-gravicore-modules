# ----------------------------------------------------------------------------------------------------------------------
# VARIABLES / LOCALS / REMOTE STATE
# ----------------------------------------------------------------------------------------------------------------------

variable "create" {
  description = "Whether to create this resource or not?"
  default     = true
}

variable "stage_prefix" {
  description = "Creates a unique name beginning with the specified prefix"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of VPC subnet IDs"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

# ----------------------------------------------------------------------------------------------------------------------
# MODULES / RESOURCES
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_db_subnet_group" "this" {
  count = var.create ? 1 : 0

  name        = var.stage_prefix
  description = "Database subnet group"
  subnet_ids  = var.subnet_ids

  tags = merge(
    var.tags,
    {
      "Name" = "RDS_subnet_group"
    },
  )
}

# ----------------------------------------------------------------------------------------------------------------------
# OUTPUTS
# ----------------------------------------------------------------------------------------------------------------------

output "this_db_subnet_group_id" {
  description = "The db subnet group name"
  value       = element(concat(aws_db_subnet_group.this.*.id, [""]), 0)
}

output "this_db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = element(concat(aws_db_subnet_group.this.*.arn, [""]), 0)
}


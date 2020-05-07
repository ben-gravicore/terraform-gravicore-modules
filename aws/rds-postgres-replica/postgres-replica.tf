# ----------------------------------------------------------------------------------------------------------------------
# VARIABLES / LOCALS / REMOTE STATE
# ----------------------------------------------------------------------------------------------------------------------

variable "create_load_balancer" {
  type        = bool
  default     = true
  description = ""
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "The IDs of the security groups from which to allow `ingress` traffic to the DB instance"
}

variable "ingress_sg_cidr" {
  description = "List of the ingress cidr's to create the security group."
  default     = []
  type        = list(string)
}

variable "database_port" {
  description = "Database port (_e.g._ `3306` for `MySQL`). Used in the DB Security Group to allow access to the DB instance from the provided `security_group_ids`"
}

variable "multi_az" {
  type        = bool
  description = "Set to true if multi AZ deployment must be supported"
  default     = false
}

variable "storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)."
  default     = "gp2"
}

variable "storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB instance is encrypted. The default is false if not specified."
  default     = false
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'. Default is 0 if rds storage type is not 'io1'"
  default     = "0"
}

variable "instance_class" {
  type        = string
  description = "Class of RDS instance"

  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
}

variable "publicly_accessible" {
  type        = bool
  description = "Determines if database can be publicly available (NOT recommended)"
  default     = false
}

variable "subnet_ids" {
  description = "List of subnets for the DB"
  type        = list
}

variable "vpc_id" {
  type        = string
  description = "VPC ID the DB instance will be created in"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Allow automated minor version upgrade (e.g. from Postgres 9.5.3 to Postgres 9.5.4)"
  default     = true
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Allow major version upgrade"
  default     = false
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  default     = false
}

variable "maintenance_window" {
  type        = string
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' UTC "
  default     = "Mon:03:00-Mon:04:00"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "If true (default), no snapshot will be made before deleting DB"
  default     = true
}

variable "copy_tags_to_snapshot" {
  type        = bool
  description = "Copy tags from DB to a snapshot"
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days. Must be > 0 to enable backups"
  default     = 0
}

variable "backup_window" {
  type        = string
  description = "When AWS can perform DB snapshots, can't overlap with maintenance window"
  default     = "22:00-03:00"
}

variable "snapshot_identifier" {
  type        = string
  description = "Snapshot identifier e.g: rds:production-2015-06-26-06-05. If specified, the module create cluster from the snapshot"
  default     = ""
}

variable "parameter_group_name" {
  type        = string
  description = "Name of the DB parameter group to associate"
  default     = null
}

variable "parameters" {
  description = "(Optional) If used, create new parameter group for the read replica. If not, inhearets source instance's parameter group"
  default     = null
  type        = list(map(string))
}

variable "family" {
  type        = string
  default     = null
  description = "The family of the DB parameter group"
}

variable "kms_key_id" {
  type        = string
  description = "The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN"
  default     = ""
}

variable "replicate_source_db" {
  type        = list(string)
  description = "Specifies that this resource is a Replicate database, and to use this value as the source database. This correlates to the identifier of another Amazon RDS Database to replicate. Note that if you are creating a cross-region replica of an encrypted database you will also need to specify a kms_key_id. See [DB Instance Replication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Replication.html) and [Working with PostgreSQL and MySQL Read Replicas](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html) for more information on using Replication."
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. Valid Values are 0, 1, 5, 10, 15, 30, 60."
  default     = "0"
}

variable "same_region" {
  type        = bool
  description = "Whether this replica is in the same region as the master."
  default     = true
}

variable "number_of_instances" {
  default     = 0
  description = "Number of read replicas to creat"
}

variable "enable_dns" {
  type        = bool
  description = "Create Route53 DNS entry"
  default     = false
}

variable "dns_zone_id" {
  type        = string
  description = "Route53 DNS Zone ID"
  default     = ""
}

variable "dns_zone_name" {
  type        = string
  description = "Route53 DNS Zone name"
  default     = ""
}

variable "dns_name_prefix" {
  type        = string
  description = "Route53 DNS Zone name"
  default     = ""
}

variable "type" {
  type        = string
  default     = "CNAME"
  description = "Type of DNS records to create"
}

variable "ttl" {
  type        = string
  default     = "60"
  description = "The TTL of the record to add to the DNS zone to complete certificate validation"
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled."
}

variable "max_allocated_storage" {
  type        = number
  default     = 0
  description = "(Optional) When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to allocated_storage. Must be greater than or equal to allocated_storage or 0 to disable Storage Autoscaling."
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "(Optional) If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false."
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = ["postgresql", "upgrade"]
  description = "(Optional) List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): agent (MSSQL), alert, audit, error, general, listener, slowquery, trace, postgresql (PostgreSQL), upgrade (PostgreSQL)."
}

variable "deploy_nlb" {
  type        = bool
  default     = false
  description = "(Optional) If true, all necessary recoures for creating a connection via a load balancer will be created"
}

variable "nlb_force_destroy_access_logs" {
  type        = bool
  default     = false
  description = "A boolean that indicates the bucket can be destroyed even if it contains objects. These objects are not recoverable"
}

variable "nlb_internal" {
  type        = string
  default     = false
  description = "(Optional) If true, the LB will be internal"
}

variable "nlb_subnet_ids" {
  type        = list(string)
  default     = null
  description = "(Optional) A list of subnet IDs to attach to the LB. Subnets cannot be updated. Changing this value will force a recreation of the resource"
}

variable "nlb_enable_cross_zone_load_balancing" {
  type        = bool
  default     = false
  description = "(Optional) If true, cross-zone load balancing of the load balancer will be enabled"
}

variable "nlb_ip_address_type" {
  type        = string
  default     = null
  description = "(Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack"
}

variable "nlb_deletion_protection_enabled" {
  type        = bool
  default     = true
  description = "(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer"
}

variable "nbl_access_logs_prefix" {
  type        = string
  default     = ""
  description = "(Optional) The S3 bucket prefix. Logs are stored in the root if not configured"
}

variable "enable_nlb_access_logs" {
  type        = bool
  default     = true
  description = "(Optional) Boolean to enable / disable access_logs"
}

variable "nlb_deregistration_delay" {
  type        = number
  default     = 30
  description = "(Optional) The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds"
}

variable "nlb_listener_port" {
  type        = number
  default     = null
  description = "(Optional) The port on which the load balancer is listening"
}

variable "nlb_certificate_arn" {
  type        = string
  default     = null
  description = "(Optional) The ARN of the default SSL server certificate"
}

variable "nlb_ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
  description = "(Optional) The name of the SSL Policy for the listener. Required if TLS"
}

variable "nlb_listener_protocol" {
  type        = string
  default     = null
  description = "(Optional) The protocol for connections from clients to the load balancer. Valid values are TCP, TLS"
}

variable "nlb_health_check_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Indicates whether health checks are enabled"
}

variable "nlb_health_check_interval" {
  type        = number
  default     = 30
  description = "(Optional) The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds"
}

variable "nlb_health_check_threshold" {
  type        = number
  default     = 3
  description = "(Optional) The number of consecutive health checks successes/failures required before considering an healthy/unhealthy target healthy"
}

variable "nlb_dns_zone_id" {
  type        = string
  description = "Route53 DNS Zone ID"
  default     = ""
}

variable "nlb_dns_zone_name" {
  type        = string
  description = "Route53 DNS Zone name"
  default     = ""
}

variable "nlb_dns_name_prefix" {
  type        = string
  description = "Route53 DNS Zone name"
  default     = "db"
}

# ----------------------------------------------------------------------------------------------------------------------
# MODULES / RESOURCES
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_db_instance" "default" {
  count                       = var.create ? var.number_of_instances : 0
  identifier                  = format("${local.module_prefix}-%01d", count.index + 1)
  port                        = var.database_port
  instance_class              = var.instance_class
  storage_encrypted           = var.storage_encrypted
  vpc_security_group_ids      = ["${aws_security_group.replica[0].id}"]
  multi_az                    = var.multi_az
  storage_type                = var.storage_type
  iops                        = var.iops
  publicly_accessible         = var.publicly_accessible
  snapshot_identifier         = var.snapshot_identifier
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window
  skip_final_snapshot         = var.skip_final_snapshot
  copy_tags_to_snapshot       = var.copy_tags_to_snapshot
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  tags                        = local.tags
  kms_key_id                  = var.kms_key_id
  monitoring_interval         = var.monitoring_interval
  replicate_source_db         = var.replicate_source_db[0]

  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  max_allocated_storage               = var.max_allocated_storage
  deletion_protection                 = var.deletion_protection
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
}

# Security group
resource "aws_security_group" "replica" {
  count       = var.create ? 1 : 0
  name        = "${local.module_prefix}-replica"
  description = format("%s %s", var.desc_prefix, "Allow inbound traffic to read replicas")
  vpc_id      = var.vpc_id

  tags = local.tags
}

resource "aws_security_group_rule" "allow_ingress_sg" {
  count                    = var.create ? length(var.security_group_ids) : 0
  security_group_id        = aws_security_group.replica[0].id
  type                     = "ingress"
  from_port                = var.database_port
  to_port                  = var.database_port
  protocol                 = "tcp"
  source_security_group_id = var.security_group_ids[count.index]
}

resource "aws_security_group_rule" "allow_ingress_cidr" {
  count             = var.create && length(var.ingress_sg_cidr) > 0 ? 1 : 0
  security_group_id = aws_security_group.replica[0].id
  type              = "ingress"
  from_port         = var.database_port
  to_port           = var.database_port
  protocol          = "tcp"
  cidr_blocks       = var.ingress_sg_cidr
}

resource "aws_security_group_rule" "allow_egress" {
  count             = var.create ? 1 : 0
  security_group_id = aws_security_group.replica[0].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_route53_record" "default" {
  count   = var.create && var.enable_dns ? length(aws_db_instance.default.*.name) : 0
  zone_id = var.dns_zone_id
  name    = join(".", [var.dns_name_prefix, var.dns_zone_name])
  type    = var.type
  ttl     = var.ttl
  records = [aws_db_instance.default[count.index].address]

  set_identifier = "read-replica-${count.index}"

  weighted_routing_policy {
    weight = 10
  }

}

# NLB 

# module "nlb_access_logs" {
#   source    = "git::https://github.com/cloudposse/terraform-aws-lb-s3-bucket.git?ref=tags/0.3.0"
#   enabled   = var.create && var.deploy_nlb && var.enable_nlb_access_logs
#   name      = "${local.module_prefix}-nlb-access-logs"
#   namespace = ""
#   stage     = ""

#   region        = var.aws_region
#   force_destroy = var.nlb_force_destroy_access_logs
#   tags          = local.tags
# }

resource "aws_lb" "nlb" {
  count = var.create && var.deploy_nlb ? 1 : 0
  name  = local.module_prefix

  load_balancer_type = "network"
  internal           = var.nlb_internal

  subnets                          = var.nlb_subnet_ids
  enable_cross_zone_load_balancing = var.nlb_enable_cross_zone_load_balancing
  ip_address_type                  = var.nlb_ip_address_type
  enable_deletion_protection       = var.nlb_deletion_protection_enabled
  # access_logs {
  #   bucket  = module.nlb_access_logs.bucket_id
  #   prefix  = var.nbl_access_logs_prefix
  #   enabled = var.enable_nlb_access_logs
  # }
  tags = local.tags
}

# data "aws_elb_service_account" "nlb_access_log" {
#   count = var.create && var.deploy_nlb && var.enable_nlb_access_logs ? 1 : 0
# }

# data "aws_iam_policy_document" "nlb_access_log" {
#   count = var.create && var.deploy_nlb && var.enable_nlb_access_logs ? 1 : 0

#   statement {
#     sid = ""
#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = [data.aws_elb_service_account.nlb_access_log[0].arn]
#     }

#     actions   = ["s3:PutObject"]
#     resources = ["arn:aws:s3:::${local.module_prefix}-nlb-access-logs/*"]
#   }

#   statement {
#     sid    = "AWSLogDeliveryWrite"
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["delivery.logs.amazonaws.com"]
#     }

#     actions   = ["s3:PutObject"]
#     resources = ["arn:aws:s3:::${local.module_prefix}-nlb-access-logs/*"]

#     condition {
#       test     = "StringLike"
#       variable = "s3:x-amz-acl"
#       values   = ["bucket-owner-full-control"]
#     }
#   }

#   statement {
#     sid    = "AWSLogDeliveryAclCheck"
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["delivery.logs.amazonaws.com"]
#     }

#     actions   = ["s3:GetBucketAcl"]
#     resources = ["arn:aws:s3:::${local.module_prefix}-nlb-access-logs/*"]
#   }
# }

# module "nlb_access_logs" {
#   source    = "git::https://github.com/cloudposse/terraform-aws-s3-log-storage.git?ref=tags/0.7.0"
#   enabled   = var.create && var.deploy_nlb && var.enable_nlb_access_logs
#   name      = "${local.module_prefix}-nlb-access-logs"
#   namespace = ""
#   stage     = ""

#   region        = var.aws_region
#   force_destroy = var.nlb_force_destroy_access_logs
#   tags          = local.tags
#   policy        = data.aws_iam_policy_document.nlb_access_log[0].json
# }

resource "aws_lb_target_group" "nlb" {
  count = var.create && var.deploy_nlb ? 1 : 0
  name  = local.module_prefix

  vpc_id               = var.vpc_id
  port                 = var.database_port
  protocol             = "TCP"
  target_type          = "ip"
  deregistration_delay = var.nlb_deregistration_delay
  health_check {
    protocol            = "TCP"
    enabled             = var.nlb_health_check_enabled
    healthy_threshold   = var.nlb_health_check_threshold
    unhealthy_threshold = var.nlb_health_check_threshold
    interval            = var.nlb_health_check_interval
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = local.tags
}

resource "aws_route53_record" "nlb" {
  count   = var.create && var.deploy_nlb ? 1 : 0
  zone_id = var.nlb_dns_zone_id
  name    = join(".", [var.nlb_dns_name_prefix, var.nlb_dns_zone_name])
  type    = var.type
  ttl     = var.ttl
  records = ["${aws_lb.nlb[0].dns_name}"]
}

resource "aws_lb_listener" "nlb" {
  count = var.create && var.deploy_nlb ? 1 : 0

  load_balancer_arn = aws_lb.nlb[0].arn
  port              = coalesce(var.nlb_listener_port, var.database_port)
  protocol          = coalesce(var.nlb_listener_protocol, var.nlb_certificate_arn != null ? "TLS" : "TCP")
  ssl_policy        = var.nlb_certificate_arn != null ? var.nlb_ssl_policy : null
  certificate_arn   = var.nlb_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb[0].arn
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# OUTPUTS
# ----------------------------------------------------------------------------------------------------------------------

output "pg_replica_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.default[*].address
}

resource "aws_ssm_parameter" "pg_replica_instance_address" {
  count       = var.create ? 1 : 0
  name        = "/${local.stage_prefix}/${var.name}-address"
  description = format("%s %s", var.desc_prefix, "The address of the RDS instance")

  type      = "StringList"
  value     = join(",", aws_db_instance.default[*].address)
  overwrite = true
  tags      = local.tags
}

output "pg_replica_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.default[*].arn
}

resource "aws_ssm_parameter" "pg_replica_instance_arn" {
  count       = var.create ? 1 : 0
  name        = "/${local.stage_prefix}/${var.name}-arn"
  description = format("%s %s", var.desc_prefix, "The ARN of the RDS instance")

  type      = "StringList"
  value     = join(",", aws_db_instance.default[*].arn)
  overwrite = true
  tags      = local.tags
}

output "pg_replica_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = aws_db_instance.default[*].availability_zone
}

output "pg_replica_instance_multi_az" {
  description = "If the RDS instance is multi AZ enabled"
  value       = aws_db_instance.default[*].multi_az
}

output "pg_replica_instance_storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  value       = aws_db_instance.default[*].storage_encrypted
}

output "pg_replica_instance_endpoint" {
  description = "The connection endpoint in address:port format"
  value       = aws_db_instance.default[*].endpoint
}

resource "aws_ssm_parameter" "pg_replica_instance_endpoint" {
  count       = var.create ? 1 : 0
  name        = "/${local.stage_prefix}/${var.name}-endpoint"
  description = format("%s %s", var.desc_prefix, "The connection endpoint in address:port format")

  type      = "StringList"
  value     = join(",", aws_db_instance.default[*].endpoint)
  overwrite = true
  tags      = local.tags
}

output "pg_replica_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = aws_db_instance.default[*].hosted_zone_id
}

resource "aws_ssm_parameter" "pg_replica_instance_hosted_zone_id" {
  count       = var.create ? 1 : 0
  name        = "/${local.stage_prefix}/${var.name}-hosted-zone-id"
  description = format("%s %s", var.desc_prefix, "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)")

  type      = "StringList"
  value     = join(",", aws_db_instance.default[*].hosted_zone_id)
  overwrite = true
  tags      = local.tags
}

output "pg_replica_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.default[*].id
}

resource "aws_ssm_parameter" "pg_replica_instance_id" {
  count       = var.create ? 1 : 0
  name        = "/${local.stage_prefix}/${var.name}-service-access-key-id"
  description = format("%s %s", var.desc_prefix, "The RDS instance ID")

  type      = "StringList"
  value     = join(",", aws_db_instance.default[*].id)
  overwrite = true
  tags      = local.tags
}

output "pg_replica_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.default[*].status
}

output "pg_replica_instance_port" {
  description = "The database port"
  value       = aws_db_instance.default[*].port
}

resource "aws_ssm_parameter" "pg_replica_instance_port" {
  count       = var.create ? 1 : 0
  name        = "/${local.stage_prefix}/${var.name}-port"
  description = format("%s %s", var.desc_prefix, "The database port")

  type      = "StringList"
  value     = join(",", aws_db_instance.default[*].port)
  overwrite = true
  tags      = local.tags
}

output "pg_replica_security_group_name" {
  description = "The name of the db security group"
  value       = aws_security_group.replica.*.name
}

resource "aws_ssm_parameter" "pg_replica_security_group_name" {
  count       = var.create ? 1 : 0
  name        = "/${local.stage_prefix}/${var.name}-security-group-name"
  description = format("%s %s", var.desc_prefix, "The name of the db security group")

  type      = "StringList"
  value     = join(",", aws_security_group.replica.*.name)
  overwrite = true
  tags      = local.tags
}

output "pg_replica_nlb_endpoint" {
  description = "DNS enpoint of the nlb"
  value       = aws_lb.nlb[0].dns_name
}

output "pg_replica_nlb_route53_record" {
  description = "Route53 DNS enpoint of the nlb"
  value       = aws_route53_record.nlb[0].fqdn
}

# output "pg_replica_nlb_access_log_bucket_id" {
#   description = "Route53 DNS enpoint of the nlb"
#   value       = module.nlb_access_logs.bucket_id
# }

# ----------------------------------------------------------------------------------------------------------------------
# VARIABLES / LOCALS / REMOTE STATE
# ----------------------------------------------------------------------------------------------------------------------

variable "parent_domain_name" {}

variable "aws_subdomain_name" {
  default = "aws"
}

variable "cidr_network" {
  default = "10.0"
}

variable "parameter_store_kms_arn" {
  type        = "string"
  default     = "alias/parameter_store_key"
  description = "The ARN of a KMS key used to encrypt and decrypt SecretString values"
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default     = false
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  default     = false
}

variable "enable_dynamodb_endpoint" {
  description = "Should be true if you want to provision a DynamoDB endpoint to the VPC"
  default     = true
}

variable "enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  default     = true
}

variable "enable_sqs_endpoint" {
  description = "Should be true if you want to provision an SQS endpoint to the VPC"
  default     = false
}

variable "enable_ssm_endpoint" {
  description = "Should be true if you want to provision an SSM endpoint to the VPC"
  default     = false
}

variable "enable_ssmmessages_endpoint" {
  description = "Should be true if you want to provision a SSMMESSAGES endpoint to the VPC"
  default     = false
}

variable "enable_apigw_endpoint" {
  description = "Should be true if you want to provision an api gateway endpoint to the VPC"
  default     = false
}

variable "enable_ec2_endpoint" {
  description = "Should be true if you want to provision an EC2 endpoint to the VPC"
  default     = false
}

variable "enable_ec2messages_endpoint" {
  description = "Should be true if you want to provision an EC2MESSAGES endpoint to the VPC"
  default     = false
}

variable "enable_ecr_api_endpoint" {
  description = "Should be true if you want to provision an ecr api endpoint to the VPC"
  default     = false
}

variable "enable_ecr_dkr_endpoint" {
  description = "Should be true if you want to provision an ecr dkr endpoint to the VPC"
  default     = false
}

variable "enable_kms_endpoint" {
  description = "Should be true if you want to provision a KMS endpoint to the VPC"
  default     = false
}

variable "enable_ecs_endpoint" {
  description = "Should be true if you want to provision a ECS endpoint to the VPC"
  default     = false
}

variable "enable_ecs_agent_endpoint" {
  description = "Should be true if you want to provision a ECS Agent endpoint to the VPC"
  default     = false
}

variable "enable_ecs_telemetry_endpoint" {
  description = "Should be true if you want to provision a ECS Telemetry endpoint to the VPC"
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

# ----------------------------------------------------------------------------------------------------------------------
# MODULES / RESOURCES
# ----------------------------------------------------------------------------------------------------------------------

# Create a default key/pair for public and private instances

module "ssh_key_pair_public" {
  source    = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=0.4.0"
  namespace = var.namespace
  stage     = var.stage
  name      = "${var.environment}-${var.name}-public"
  tags      = local.tags

  ssh_public_key_path   = "${pathexpand("~/.ssh")}/${var.namespace}"
  generate_ssh_key      = var.create
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
  chmod_command         = "chmod 600 %v"
}

module "ssh_key_pair_private" {
  source    = "./key-pair"
  namespace = var.namespace
  stage     = var.stage
  name      = "${var.environment}-${var.name}-private"
  tags      = local.tags

  ssh_public_key_path   = "${pathexpand("~/.ssh")}/${var.namespace}"
  generate_ssh_key      = var.create
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
  chmod_command         = "chmod 600 %v"
}

locals {
  ssh_secret_ssm_write = [
    {
      name        = "/${local.stage_prefix}/${var.name}-private-pem"
      value       = module.ssh_key_pair_private.private_key
      type        = "SecureString"
      overwrite   = "true"
      description = join(" ", list(var.desc_prefix, "Private SSH Key for EC2 Instances in Private VPC Subnet"))
    },
    {
      name        = "/${local.stage_prefix}/${var.name}-private-pub"
      value       = module.ssh_key_pair_private.public_key
      type        = "SecureString"
      overwrite   = "true"
      description = join(" ", list(var.desc_prefix, "Public SSH Key for EC2 Instances in Private VPC Subnet"))
    },
  ]

  # `ssh_secret_ssm_write_count` needs to be updated if `ssh_secret_ssm_write` changes
  ssh_secret_ssm_write_count = 2
}

resource "aws_ssm_parameter" "default" {
  count           = "${var.create ? local.ssh_secret_ssm_write_count : 0}"
  name            = lookup(local.ssh_secret_ssm_write[count.index], "name")
  description     = lookup(local.ssh_secret_ssm_write[count.index], "description", lookup(local.ssh_secret_ssm_write[count.index], "name"))
  type            = lookup(local.ssh_secret_ssm_write[count.index], "type", "SecureString")
  key_id          = "${lookup(local.ssh_secret_ssm_write[count.index], "type", "SecureString") == "SecureString" && length(var.parameter_store_kms_arn) > 0 ? var.parameter_store_kms_arn : ""}"
  value           = lookup(local.ssh_secret_ssm_write[count.index], "value")
  overwrite       = lookup(local.ssh_secret_ssm_write[count.index], "overwrite", "false")
  allowed_pattern = lookup(local.ssh_secret_ssm_write[count.index], "allowed_pattern", "")
  tags            = local.tags
}

module "vpc" {
  source     = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc?ref=v2.17.0"
  create_vpc = var.create
  name       = local.module_prefix
  tags       = local.tags

  azs                           = ["${var.aws_region}a", "${var.aws_region}b"]
  cidr                          = "${var.cidr_network}.0.0/16"
  private_subnets               = ["${var.cidr_network}.0.0/19", "${var.cidr_network}.32.0/19"]
  public_subnets                = ["${var.cidr_network}.128.0/20", "${var.cidr_network}.144.0/20"]
  map_public_ip_on_launch       = var.map_public_ip_on_launch
  enable_nat_gateway            = var.enable_nat_gateway
  single_nat_gateway            = var.single_nat_gateway
  one_nat_gateway_per_az        = var.one_nat_gateway_per_az
  enable_dynamodb_endpoint      = var.enable_dynamodb_endpoint
  enable_s3_endpoint            = var.enable_s3_endpoint
  enable_dns_support            = var.enable_dns_support
  enable_dns_hostnames          = var.enable_dns_hostnames
  enable_sqs_endpoint           = var.enable_sqs_endpoint
  enable_ssm_endpoint           = var.enable_ssm_endpoint
  enable_ssmmessages_endpoint   = var.enable_ssmmessages_endpoint
  enable_apigw_endpoint         = var.enable_apigw_endpoint
  enable_ec2_endpoint           = var.enable_ec2_endpoint
  enable_ecr_api_endpoint       = var.enable_ecr_api_endpoint
  enable_ecr_dkr_endpoint       = var.enable_ecr_dkr_endpoint
  enable_kms_endpoint           = var.enable_kms_endpoint
  enable_ecs_endpoint           = var.enable_ecs_endpoint
  enable_ecs_agent_endpoint     = var.enable_ecs_agent_endpoint
  enable_ecs_telemetry_endpoint = var.enable_ecs_telemetry_endpoint
}

# ----------------------------------------------------------------------------------------------------------------------
# OUTPUTS
# ----------------------------------------------------------------------------------------------------------------------

// VPC module outputs

output "vpc_subnet_ids" {
  value = concat(
    module.vpc.private_subnets,
    module.vpc.public_subnets,
    module.vpc.database_subnets,
    module.vpc.redshift_subnets,
    module.vpc.elasticache_subnets,
    module.vpc.intra_subnets
  )
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.vpc.default_security_group_id
}

output "vpc_default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = module.vpc.default_network_acl_id
}

output "vpc_default_route_table_id" {
  description = "The ID of the default route table"
  value       = module.vpc.default_route_table_id
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = module.vpc.vpc_instance_tenancy
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = module.vpc.vpc_enable_dns_support
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = module.vpc.vpc_enable_dns_hostnames
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = module.vpc.vpc_main_route_table_id
}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = module.vpc.vpc_secondary_cidr_blocks
}

output "vpc_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "vpc_private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "vpc_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "vpc_public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "vpc_public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.vpc.public_route_table_ids
}

output "vpc_private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

output "vpc_nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_ids
}

output "vpc_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "vpc_natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

output "vpc_igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

output "vpc_endpoint_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = module.vpc.vpc_endpoint_s3_id
}

output "vpc_endpoint_s3_pl_id" {
  description = "The prefix list for the S3 VPC endpoint."
  value       = module.vpc.vpc_endpoint_s3_pl_id
}

output "vpc_endpoint_dynamodb_id" {
  description = "The ID of VPC endpoint for DynamoDB"
  value       = module.vpc.vpc_endpoint_dynamodb_id
}

output "vpc_vgw_id" {
  description = "The ID of the VPN Gateway"
  value       = module.vpc.vgw_id
}

output "vpc_endpoint_dynamodb_pl_id" {
  description = "The prefix list for the DynamoDB VPC endpoint."
  value       = module.vpc.vpc_endpoint_dynamodb_pl_id
}

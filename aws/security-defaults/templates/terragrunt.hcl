# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that supports locking and enforces best
# practices: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  # source = "../../../terraform-gravicore-modules/aws//default"
  source = "git::https://github.com/ben-gravicore/terraform-gravicore-modules.git//aws/security-defaults"
}

# Include all settings from the root terraform.tfvars file
include {
  path = find_in_parent_folders()
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  default_aws_security_group_vpc_id = ""
}

# Configure root level variables that all resources can inherit
terraform {
  before_hook "providers" {
    commands     = ["init"]
    execute      = ["bash", "-c", "cp -f ../../providers*.tf . 2>/dev/null || :"]
    run_on_error = false
  }
}
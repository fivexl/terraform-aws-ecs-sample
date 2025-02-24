variable "networking_account_id" {
  description = "Id of the networking account"
  type = string
}

variable "vpc" {
  description = "VPC configuration"
  type = object({
    name               = string
  })
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "db" {
  description = "DB configuration"
  type = object({
    engine_version                        = string
    instance_class                        = string
    allocated_storage                     = number
    auto_minor_version_upgrade            = bool
    allow_major_version_upgrade           = bool
    apply_immediately                     = bool
    backup_retention_period               = number
    performance_insights_enabled          = bool
    multi_az                              = bool
    performance_insights_retention_period = number
    enchanced_monitoring_interval         = number
    max_allocated_storage                 = number
  })
}

variable "tags" {
  type = object({
    environment_name = string
    environment_type = string
    data_pci         = string
    data_phi         = string
    data_pii         = string
    prefix           = string
    data_owner       = string
  })
}

variable "primary_region" {
  type = string
}

variable "secondary_region" {
  type = string
}

variable "dns_zone_name" {
  type = string
}

variable "create_ecr_resources" {
  description = "Create ECR resources"
  type        = bool
  default     = true
}

variable "allow_ecr_get_for_account_ids" {
  description = "Account IDs to allow cross-account access to ECR repositories"
  type        = list(string)
  default     = []
}

variable "ecr_image_version" {
  description = "The version of the image to use in the ECS service, by default it will use latest commit hash"
  type        = string
  default     = ""
}

variable "dev_account_id" {
  description = "The account ID of the development account"
  type        = string
  default     = ""
}

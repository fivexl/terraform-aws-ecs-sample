variable "name" {
  type = string
}

variable "service_discovery_namespace_arn" {
  type = string
}

variable "access_logs_bucket_id" {
  type = string
}

variable "services" {
  type = any
}

variable "private_subnets" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}
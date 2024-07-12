variable "name" {
  type = string
}

variable "service_discovery_namespace_arn" {
  type = string
}

variable "service_discovery_namespace_id" {
  type = string
}

variable "access_logs_bucket_id" {
  type = string
}

variable "tls_tester_security_group_id" {
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

variable "enable_service_connect" {
  type    = bool
  default = true
}
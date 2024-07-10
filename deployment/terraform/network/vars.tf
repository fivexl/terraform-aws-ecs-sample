variable "access_logs_bucket_name" {
  type = string
}

variable "dns_admin_role_arn" {
  type = string
}

variable "dns_zone_name" {
  type = string
}

variable "services" {
  type = any
}

variable "name" {
  type = string
}
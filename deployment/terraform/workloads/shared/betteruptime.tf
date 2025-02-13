# TODO:
# locals {
#   betteruptime_monitors_list = { for k, v in local.services : k => "${v.domain_name}.${data.aws_route53_zone.primary_public.name}${v.health_check_path}" if try(v.domain_name, "") != "" }
# }

# resource "betteruptime_monitor_group" "this" {
#   count  = length(local.betteruptime_monitors_list) > 0 ? 1 : 0
#   name   = var.tags.environment_name
#   paused = false
# }

# resource "betteruptime_monitor" "this" {
#   for_each         = local.betteruptime_monitors_list

#   monitor_group_id = betteruptime_monitor_group.this[0].id
#   monitor_type     = "status"
#   url              = "https://${each.value}"
#   check_frequency  = 180
#   paused           = false
#   regions          = ["us", "eu", "as", "au"]
#   ssl_expiration   = 3
#   verify_ssl       = true
#   recovery_period  = 180
#   email            = true
# }

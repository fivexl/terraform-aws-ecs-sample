module "tags" {
  source            = "fivexl/tag-generator/aws"
  version           = "2.0.0"
  terraform_managed = "1"
  environment_name  = local.name
  environment_type  = "demo"
  data_pci          = "0"
  data_phi          = "0"
  data_pii          = "0"
  prefix            = "fivexl"
  data_owner        = "demo-master"
}
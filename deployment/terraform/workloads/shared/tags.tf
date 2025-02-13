module "tags" {
  source            = "fivexl/tag-generator/aws"
  version           = "2.0.0"
  terraform_managed = "1"

  environment_name = var.tags.environment_name
  environment_type = var.tags.environment_type

  data_pci = var.tags.data_pci
  data_phi = var.tags.data_phi
  data_pii = var.tags.data_pii

  prefix     = var.tags.prefix
  data_owner = var.tags.data_owner
}
 
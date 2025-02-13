provider "aws" { # Default provider
  region = var.primary_region

  default_tags {
    tags = module.tags.result
  }
}

provider "aws" {
  alias  = "primary"
  region = var.primary_region

  default_tags {
    tags = module.tags.result
  }
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region

  default_tags {
    tags = module.tags.result
  }
}

provider "aws" {
  alias  = "dns"
  region = var.primary_region
  default_tags {
    tags = module.tags.result
  }
  assume_role {
    role_arn     = "arn:aws:iam::${var.networking_account_id}:role/dns-admin"
    session_name = "dev-workloads1"
  }
}

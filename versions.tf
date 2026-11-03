# Versions de Terraform et du fournisseur AWS.
# Le fournisseur n'est jamais épinglé sur une version exacte : la
# contrainte souple permet les correctifs sans casser le code.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# La région est une variable pour déployer ailleurs sans toucher au code.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Projet        = var.nom_projet
      Environnement = var.environnement
      GéréPar       = "terraform"
    }
  }
}

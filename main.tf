# Assemblage : les modules sont reliés entre eux par leurs sorties.
# L'ordre compte : le réseau d'abord, puis le calcul (dont le groupe de
# sécurité est passé à la base), puis la base et le stockage.

module "reseau" {
  source = "./modules/reseau"

  nom_projet    = var.nom_projet
  environnement = var.environnement
  cidr_vpc      = var.cidr_vpc
  cidr_publics  = var.cidr_publics
  cidr_prives   = var.cidr_prives
}

module "calcul" {
  source = "./modules/calcul"

  nom_projet         = var.nom_projet
  environnement      = var.environnement
  vpc_id             = module.reseau.vpc_id
  sous_reseau_public = module.reseau.sous_reseaux_publics[0]
  type_instance      = var.type_instance
  ami_id             = var.ami_id
}

module "base" {
  source = "./modules/base"

  nom_projet             = var.nom_projet
  environnement          = var.environnement
  vpc_id                 = module.reseau.vpc_id
  sous_reseaux_prives    = module.reseau.sous_reseaux_prives
  groupe_securite_calcul = module.calcul.groupe_securite_id
  classe_base            = var.classe_base
  utilisateur_base       = var.utilisateur_base
  mot_de_passe_base      = var.mot_de_passe_base
  multi_az               = var.environnement == "prod"
}

module "stockage" {
  source = "./modules/stockage"

  nom_projet    = var.nom_projet
  environnement = var.environnement
  versionnement = var.environnement == "prod"
}

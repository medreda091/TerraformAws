variable "nom_projet" {
  description = "Préfixe appliqué aux noms des ressources."
  type        = string
}

variable "environnement" {
  description = "Environnement déployé : dev ou prod."
  type        = string
}

variable "vpc_id" {
  description = "Identifiant du VPC où placer la base."
  type        = string
}

variable "sous_reseaux_prives" {
  description = "Sous-réseaux privés qui hébergent la base."
  type        = list(string)
}

variable "groupe_securite_calcul" {
  description = "Groupe de sécurité du serveur applicatif, seul autorisé à joindre la base."
  type        = string
}

variable "classe_base" {
  description = "Classe d'instance RDS."
  type        = string
}

variable "utilisateur_base" {
  description = "Nom de l'utilisateur principal de la base."
  type        = string
}

variable "mot_de_passe_base" {
  description = "Mot de passe de la base, marqué sensible."
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "Déploie une réplique dans une seconde zone (prod)."
  type        = bool
  default     = false
}

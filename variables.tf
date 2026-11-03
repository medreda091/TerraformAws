# Variables globales du projet. Chaque module reçoit uniquement ce dont
# il a besoin : aucune ressource ne lit une variable qui ne la concerne pas.

variable "region" {
  description = "Région AWS du déploiement (eu-west-3 = Paris par défaut)."
  type        = string
  default     = "eu-west-3"
}

variable "nom_projet" {
  description = "Préfixe appliqué aux noms des ressources."
  type        = string
  default     = "terraformaws"
}

variable "environnement" {
  description = "Environnement déployé : dev ou prod."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environnement)
    error_message = "L'environnement doit être dev ou prod."
  }
}

variable "cidr_vpc" {
  description = "Plage d'adresses du VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "cidr_publics" {
  description = "Plages des sous-réseaux publics (une par zone de disponibilité)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cidr_prives" {
  description = "Plages des sous-réseaux privés (une par zone de disponibilité)."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "type_instance" {
  description = "Type d'instance EC2 du serveur applicatif."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Identifiant de l'image (AMI) du serveur. À adapter à la région."
  type        = string
  default     = "ami-0f9d5c1d0e5b8a123"
}

variable "classe_base" {
  description = "Classe d'instance de la base de données RDS."
  type        = string
  default     = "db.t3.micro"
}

variable "utilisateur_base" {
  description = "Nom de l'utilisateur principal de la base de données."
  type        = string
  default     = "admin"
}

variable "mot_de_passe_base" {
  description = "Mot de passe de la base. Ne jamais le mettre en clair dans un fichier versionné : le passer avec -var ou une variable d'environnement TF_VAR_mot_de_passe_base."
  type        = string
  sensitive   = true
}

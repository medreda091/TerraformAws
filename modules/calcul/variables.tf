variable "nom_projet" {
  description = "Préfixe appliqué aux noms des ressources."
  type        = string
}

variable "environnement" {
  description = "Environnement déployé : dev ou prod."
  type        = string
}

variable "vpc_id" {
  description = "Identifiant du VPC où placer le serveur."
  type        = string
}

variable "sous_reseau_public" {
  description = "Sous-réseau public qui héberge le serveur."
  type        = string
}

variable "type_instance" {
  description = "Type d'instance EC2."
  type        = string
}

variable "ami_id" {
  description = "Identifiant de l'image (AMI) du serveur."
  type        = string
}

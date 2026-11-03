variable "nom_projet" {
  description = "Préfixe appliqué aux noms des ressources."
  type        = string
}

variable "environnement" {
  description = "Environnement déployé : dev ou prod."
  type        = string
}

variable "cidr_vpc" {
  description = "Plage d'adresses du VPC."
  type        = string
}

variable "cidr_publics" {
  description = "Plages des sous-réseaux publics."
  type        = list(string)
}

variable "cidr_prives" {
  description = "Plages des sous-réseaux privés."
  type        = list(string)
}

variable "zones" {
  description = "Zones de disponibilité utilisées, une par sous-réseau."
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]
}

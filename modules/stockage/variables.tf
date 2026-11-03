variable "nom_projet" {
  description = "Préfixe appliqué aux noms des ressources."
  type        = string
}

variable "environnement" {
  description = "Environnement déployé : dev ou prod."
  type        = string
}

variable "versionnement" {
  description = "Active la conservation des versions précédentes des objets."
  type        = bool
  default     = true
}

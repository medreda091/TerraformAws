output "vpc_id" {
  description = "Identifiant du VPC créé."
  value       = module.reseau.vpc_id
}

output "ip_publique_serveur" {
  description = "Adresse IP publique du serveur applicatif."
  value       = module.calcul.ip_publique
}

output "point_acces_base" {
  description = "Adresse de connexion à la base de données."
  value       = module.base.point_acces
  sensitive   = true
}

output "nom_bucket" {
  description = "Nom du bucket S3 créé."
  value       = module.stockage.nom_bucket
}

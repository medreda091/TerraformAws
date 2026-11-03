output "vpc_id" {
  description = "Identifiant du VPC."
  value       = aws_vpc.principal.id
}

output "sous_reseaux_publics" {
  description = "Identifiants des sous-réseaux publics."
  value       = aws_subnet.publics[*].id
}

output "sous_reseaux_prives" {
  description = "Identifiants des sous-réseaux privés."
  value       = aws_subnet.prives[*].id
}

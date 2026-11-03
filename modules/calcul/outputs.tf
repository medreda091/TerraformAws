output "groupe_securite_id" {
  description = "Identifiant du groupe de sécurité du serveur, utilisé par la base."
  value       = aws_security_group.calcul.id
}

output "ip_publique" {
  description = "Adresse IP publique du serveur."
  value       = aws_instance.serveur.public_ip
}

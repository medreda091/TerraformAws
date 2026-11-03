output "point_acces" {
  description = "Adresse de connexion à la base (sans le port)."
  value       = aws_db_instance.principale.address
}

output "port" {
  description = "Port de la base."
  value       = aws_db_instance.principale.port
}

# Base de données : MySQL RDS dans les sous-réseaux privés, jamais
# accessible depuis internet. Seul le groupe de sécurité du serveur
# applicatif peut joindre le port 3306, et les sauvegardes sont
# conservées 7 jours.

resource "aws_db_subnet_group" "principal" {
  name       = "${var.nom_projet}-${var.environnement}-bd"
  subnet_ids = var.sous_reseaux_prives

  tags = {
    Name = "${var.nom_projet}-${var.environnement}-bd"
  }
}

resource "aws_security_group" "base" {
  name        = "${var.nom_projet}-${var.environnement}-sg-bd"
  description = "Accès MySQL réservé au serveur applicatif."
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL depuis le serveur applicatif uniquement."
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.groupe_securite_calcul]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "principale" {
  identifier             = "${var.nom_projet}-${var.environnement}-bd"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.classe_base
  allocated_storage      = 20
  db_name                = "application"
  username               = var.utilisateur_base
  password               = var.mot_de_passe_base
  db_subnet_group_name   = aws_db_subnet_group.principal.name
  vpc_security_group_ids = [aws_security_group.base.id]
  publicly_accessible    = false
  multi_az               = var.multi_az
  backup_retention_period = 7
  skip_final_snapshot    = true
  storage_encrypted      = true

  tags = {
    Name = "${var.nom_projet}-${var.environnement}-bd"
  }
}

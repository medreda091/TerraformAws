# Calcul : une instance EC2 dans un sous-réseau public, avec un groupe
# de sécurité qui n'ouvre que le web (80 et 443). Le port SSH n'est pas
# ouvert : l'administration passe par AWS Systems Manager, pas par un
# port exposé sur internet.

resource "aws_security_group" "calcul" {
  name        = "${var.nom_projet}-${var.environnement}-sg-web"
  description = "Trafic web entrant uniquement."
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "serveur" {
  ami                    = var.ami_id
  instance_type          = var.type_instance
  subnet_id              = var.sous_reseau_public
  vpc_security_group_ids = [aws_security_group.calcul.id]

  tags = {
    Name = "${var.nom_projet}-${var.environnement}-serveur"
  }
}

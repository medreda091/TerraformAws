# Réseau : un VPC avec deux sous-réseaux publics (derrière une passerelle
# internet) et deux sous-réseaux privés (qui sortent par une passerelle NAT
# unique, suffisante pour un environnement de démonstration).
# Les serveurs applicatifs vivent dans le public, la base dans le privé.

resource "aws_vpc" "principal" {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.nom_projet}-${var.environnement}-vpc"
  }
}

resource "aws_internet_gateway" "principal" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name = "${var.nom_projet}-${var.environnement}-igw"
  }
}

resource "aws_subnet" "publics" {
  count                   = length(var.cidr_publics)
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = var.cidr_publics[count.index]
  availability_zone       = var.zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.nom_projet}-${var.environnement}-public-${count.index}"
  }
}

resource "aws_subnet" "prives" {
  count             = length(var.cidr_prives)
  vpc_id            = aws_vpc.principal.id
  cidr_block        = var.cidr_prives[count.index]
  availability_zone = var.zones[count.index]

  tags = {
    Name = "${var.nom_projet}-${var.environnement}-prive-${count.index}"
  }
}

resource "aws_route_table" "publique" {
  vpc_id = aws_vpc.principal.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.principal.id
  }

  tags = {
    Name = "${var.nom_projet}-${var.environnement}-rt-publique"
  }
}

resource "aws_route_table_association" "publiques" {
  count          = length(aws_subnet.publics)
  subnet_id      = aws_subnet.publics[count.index].id
  route_table_id = aws_route_table.publique.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "principal" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.publics[0].id

  tags = {
    Name = "${var.nom_projet}-${var.environnement}-nat"
  }
}

resource "aws_route_table" "privee" {
  vpc_id = aws_vpc.principal.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.principal.id
  }

  tags = {
    Name = "${var.nom_projet}-${var.environnement}-rt-privee"
  }
}

resource "aws_route_table_association" "prives" {
  count          = length(aws_subnet.prives)
  subnet_id      = aws_subnet.prives[count.index].id
  route_table_id = aws_route_table.privee.id
}

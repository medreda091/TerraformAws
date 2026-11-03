# Tests de l'infrastructure : ils relisent les fichiers Terraform et
# vérifient la structure et les règles de sécurité, sans jamais toucher
# à AWS. Bibliothèque standard uniquement, pour tourner partout.
"""Tests de validation des fichiers Terraform du projet."""

import re
import unittest
from pathlib import Path

RACINE = Path(__file__).resolve().parent.parent
MODULES = ["reseau", "stockage", "base", "calcul"]


def lire(chemin):
    """Lit un fichier du projet et renvoie son contenu."""
    return (RACINE / chemin).read_text(encoding="utf-8")


def variables_declarees(chemin):
    """Noms des variables déclarées dans un fichier variables.tf."""
    contenu = lire(chemin)
    return re.findall(r'variable\s+"([^"]+)"', contenu)


def ressources(chemin):
    """Types et noms des ressources déclarées dans un fichier .tf."""
    contenu = lire(chemin)
    return re.findall(r'resource\s+"([^"]+)"\s+"([^"]+)"', contenu)


class TestStructure(unittest.TestCase):
    def test_modules_presents(self):
        # Chaque module possède ses trois fichiers de base.
        for module in MODULES:
            for fichier in ("main.tf", "variables.tf", "outputs.tf"):
                self.assertTrue(
                    (RACINE / "modules" / module / fichier).exists(),
                    f"il manque modules/{module}/{fichier}",
                )

    def test_racine_branche_les_quatre_modules(self):
        contenu = lire("main.tf")
        for module in MODULES:
            self.assertIn(f'module "{module}"', contenu)
            self.assertIn(f'"./modules/{module}"', contenu)

    def test_accolades_equilibrees(self):
        # Un oubli d'accolade casserait tout le déploiement : on compte.
        for fichier in RACINE.rglob("*.tf"):
            contenu = fichier.read_text(encoding="utf-8")
            sans_commentaires = re.sub(r"#.*", "", contenu)
            self.assertEqual(
                sans_commentaires.count("{"),
                sans_commentaires.count("}"),
                f"accolades déséquilibrées dans {fichier.name}",
            )


class TestReseau(unittest.TestCase):
    def test_vpc_et_passerelles(self):
        contenu = lire("modules/reseau/main.tf")
        types = [t for t, _ in ressources("modules/reseau/main.tf")]
        for attendu in ("aws_vpc", "aws_internet_gateway", "aws_nat_gateway",
                        "aws_subnet", "aws_route_table"):
            self.assertIn(attendu, types)
        self.assertIn("enable_dns_hostnames = true", contenu)

    def test_sous_reseaux_publics_et_prives(self):
        contenu = lire("modules/reseau/main.tf")
        self.assertIn("map_public_ip_on_launch = true", contenu)
        # Les sous-réseaux privés ne doivent pas recevoir d'IP publique :
        # seule la ressource publics porte cet attribut.
        self.assertEqual(contenu.count("map_public_ip_on_launch"), 1)


class TestSecurite(unittest.TestCase):
    def test_base_non_publique_et_chiffree(self):
        contenu = lire("modules/base/main.tf")
        self.assertRegex(contenu, r"publicly_accessible\s*=\s*false")
        self.assertRegex(contenu, r"storage_encrypted\s*=\s*true")
        self.assertIn("3306", contenu)
        # La base n'accepte que le groupe du serveur, pas une plage ouverte.
        bloc_ingress = contenu.split("ingress {")[1].split("}")[0]
        self.assertIn("security_groups", bloc_ingress)

    def test_calcul_sans_ssh_ouvert(self):
        contenu = lire("modules/calcul/main.tf")
        self.assertNotIn("22", contenu)
        self.assertIn("from_port   = 80", contenu)
        self.assertIn("from_port   = 443", contenu)

    def test_stockage_bloque_le_public(self):
        contenu = lire("modules/stockage/main.tf")
        self.assertIn("aws_s3_bucket_public_access_block", contenu)
        for option in ("block_public_acls", "block_public_policy",
                       "ignore_public_acls", "restrict_public_buckets"):
            self.assertRegex(contenu, rf"{option}\s*=\s*true")
        self.assertIn("AES256", contenu)

    def test_aucun_secret_en_clair(self):
        # Aucun fichier versionné ne doit contenir de mot de passe réel
        # ni de clé AWS : le mot de passe passe par une variable sensible.
        for fichier in list(RACINE.rglob("*.tf")) + list(
                (RACINE / "environnements").glob("*.tfvars")):
            contenu = fichier.read_text(encoding="utf-8")
            self.assertNotIn("AKIA", contenu, f"clé AWS dans {fichier.name}")
        variables_racine = lire("variables.tf")
        self.assertIn('variable "mot_de_passe_base"', variables_racine)
        self.assertIn("sensitive   = true", variables_racine)


class TestEnvironnements(unittest.TestCase):
    def test_dev_plus_petit_que_prod(self):
        dev = lire("environnements/dev.tfvars")
        prod = lire("environnements/prod.tfvars")
        self.assertIn('environnement = "dev"', dev)
        self.assertIn('type_instance = "t3.micro"', dev)
        self.assertIn('environnement = "prod"', prod)
        self.assertIn('type_instance = "t3.small"', prod)

    def test_prod_active_multi_az_et_versionnement(self):
        # La bascule se fait sur la valeur de l'environnement, pas en
        # dupliquant les modules : une seule condition dans main.tf.
        contenu = lire("main.tf")
        self.assertRegex(contenu, r"multi_az\s*=\s*var\.environnement == \"prod\"")
        self.assertRegex(contenu, r"versionnement\s*=\s*var\.environnement == \"prod\"")

    def test_sorties_racine(self):
        contenu = lire("outputs.tf")
        for sortie in ("vpc_id", "ip_publique_serveur",
                       "point_acces_base", "nom_bucket"):
            self.assertIn(f'output "{sortie}"', contenu)
        # L'adresse de la base est sensible : elle ne s'affiche pas en clair.
        self.assertIn("sensitive   = true", contenu)


if __name__ == "__main__":
    unittest.main()

# TerraformAws

Déployer une petite infrastructure web complète sur AWS avec Terraform :
un VPC, un serveur applicatif, une base de données privée et un bucket
de stockage — découpée en modules réutilisables, avec un environnement
de développement et un environnement de production.

## Architecture

```
Internet
   │
   ├── Sous-réseaux publics ── Serveur EC2 (HTTP/HTTPS uniquement)
   │      └── Passerelle NAT
   │
   └── Sous-réseaux privés ── Base MySQL RDS (inaccessible depuis internet)
                              Bucket S3 (privé, chiffré, versionné en prod)
```

## Modules

| Module | Contenu |
|---|---|
| `reseau` | VPC, passerelle internet, 2 sous-réseaux publics, 2 sous-réseaux privés, passerelle NAT |
| `calcul` | Instance EC2, groupe de sécurité web (80/443, pas de SSH ouvert) |
| `base` | MySQL RDS dans les sous-réseaux privés, accessible uniquement depuis le serveur, sauvegardes 7 jours, chiffrement activé |
| `stockage` | Bucket S3 privé, chiffrement côté serveur, accès public bloqué |

## Environnements

| | dev | prod |
|---|---|---|
| Instance EC2 | t3.micro | t3.small |
| Base RDS | db.t3.micro | db.t3.small, multi-AZ |
| Versionnement S3 | désactivé | activé |

La bascule se fait sur la valeur de `environnement` dans `main.tf` :
un seul code, deux configurations (`environnements/dev.tfvars` et
`environnements/prod.tfvars`).

## Prérequis

- Terraform >= 1.5
- Un compte AWS avec des identifiants configurés (`aws configure` ou
  variables d'environnement `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`)
- Python 3.12 pour les tests (bibliothèque standard uniquement)

## Déploiement

```bash
# Ne jamais mettre le mot de passe de la base dans un fichier versionné :
export TF_VAR_mot_de_passe_base="un-mot-de-passe-solide"

terraform init
terraform plan -var-file=environnements/dev.tfvars
terraform apply -var-file=environnements/dev.tfvars
```

Les sorties utiles s'affichent à la fin : identifiant du VPC, IP publique
du serveur, nom du bucket. L'adresse de la base est marquée sensible et
ne s'affiche pas en clair.

Pour détruire l'infrastructure :

```bash
terraform destroy -var-file=environnements/dev.tfvars
```

## Sécurité

- La base de données n'est **jamais** accessible depuis internet : elle
  vit dans les sous-réseaux privés et son groupe de sécurité n'autorise
  que le groupe du serveur applicatif sur le port 3306.
- Le serveur n'ouvre que les ports 80 et 443 : pas de port SSH exposé.
- Le bucket S3 bloque l'accès public sur les quatre options et chiffre
  ses objets côté serveur.
- Le mot de passe de la base est une variable sensible, passée par
  variable d'environnement ou en ligne de commande, jamais écrite dans
  un fichier versionné. L'état Terraform (`.tfstate`) est exclu par
  `.gitignore`.

## Structure du projet

```
TerraformAws/
├── main.tf                 # assemblage des modules
├── variables.tf            # variables globales
├── outputs.tf              # sorties (VPC, IP serveur, bucket)
├── versions.tf             # versions Terraform et fournisseur AWS
├── modules/
│   ├── reseau/             # VPC, sous-réseaux, NAT
│   ├── calcul/             # EC2 et groupe de sécurité web
│   ├── base/               # RDS MySQL privée
│   └── stockage/           # bucket S3
├── environnements/
│   ├── dev.tfvars
│   └── prod.tfvars
├── tests/
│   └── test_infrastructure.py
└── .github/workflows/ci.yml
```

## Tests

Les tests relisent les fichiers Terraform et vérifient la structure
(les quatre modules branchés, accolades équilibrées), les règles de
sécurité (base privée et chiffrée, pas de SSH ouvert, S3 fermé au
public, aucun secret en clair) et la cohérence des deux environnements.
Ils ne touchent pas à AWS.

```bash
python -m unittest discover -s tests -v
```

La configuration a aussi été validée avec `terraform validate`
(`Success! The configuration is valid.`) et `terraform fmt -check`.

## Licence

MIT — voir le fichier `LICENSE`.

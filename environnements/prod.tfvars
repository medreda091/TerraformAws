# Environnement de production : base multi-AZ et versionnement S3 activés
# automatiquement quand environnement = "prod" (voir main.tf).
environnement = "prod"
type_instance = "t3.small"
classe_base   = "db.t3.small"
# Le mot de passe ne figure jamais ici : passer TF_VAR_mot_de_passe_base
# ou -var "mot_de_passe_base=..." au moment du déploiement.

# Environnement de développement : petit, peu cher, sans multi-AZ.
environnement = "dev"
type_instance = "t3.micro"
classe_base   = "db.t3.micro"
# Le mot de passe ne figure jamais ici : passer TF_VAR_mot_de_passe_base
# ou -var "mot_de_passe_base=..." au moment du déploiement.

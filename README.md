# vault-ha
Installation of Hashicorp Vault HA on GCP

## Instructions
**Contexte** : Nous avons besoin pour une startup en très forte croissance, d’un outil pour gérer l’ensemble des secrets de l’entreprise. Pour cela, l’équipe a décidé de partir sur la technologie Hashicorp Vault.

**Besoin** :

- Déployer une instance Vault sur une VM et sur le cloud de votre choix. Cette instance devra être accessible sur Internet
- Créer un secret engine “production” et ajouter-y un secret
- Créer un user technique simple permettant de se connecter au secret engine production
- Avoir Vault en HA peut être un +

**Requirements** : L’ensemble de la procédure devra être reproductible et automatisée

---
# Pré-requis

- Un projet Google Cloud existant
- Un bucket pour le stockage de l'état Terraform
- Un compte de service avec les rôles suivants :
    - Storage Admin
    - Compute Admin
- Une paire de clés SSH pour la connexion sur les instances
- Un compte CircleCI pour la partie intégration continue

## Fonctionnement

Etapes :

1. Exporter la clé du compte de service au format JSON
2. Importer sur CircleCI en tant que variable d'environnement :
    - La clé du compte de service au format JSON `GCP_SERVICE_ACCOUNT`
    - La clé SSH public `VAULT_SSH_PUBLIC_KEY`
3. Importer sur CircleCI en tant que clé SSH additionnelle:
    - La clé SSH privée
4. Renseigner l'empreinte de la clé SSH privée dans le fichier .circleci/config.yml tel que :
    ```
    - add_ssh_keys:
        fingerprints:
        - 48:d2:7e:0a:67:86:04:52:ec:84:33:3a:ee:72:ec:9e
    ```

## Execution locale

1. Mettre les clés SSH privée et public dans le répertoire keys sous le nom `id_rsa`
2. Modifier le fichier `terraform/terraform.tfvars` avec vos informations
3. Configurer votre client gcloud pour pouvoir intéragir avec votre projet cible
4. Lancer le déploiement de l'infrastructure avec la commande `terraform apply` depuis le répertoire terraform
5. Construire l'inventaire Ansible avec la commande `terraform output -json ansible-inventory | jq -r '.[]' > ../ansible/inventory` depuis le répertoire terraform
6. Une fois le déploiement terminé, lancer l'installation des prérequis avec la commande `ansible-playbook -i inventory playbook.yaml` depuis le répertoire ansible
7. Une fois l'installation terminée, lancer la configuration de Vault avec la commande `sh vault/configure.sh` depuis le répertoire racine

A ce stade, l'application est configurée avec l'authentification userpass

        username : demo
        password : password

Les noeuds sont accessible sur internet avec leurs adresse IP publique (voir le fichier `ansible/inventory`).

Les informations de connexion root sont inscrites dant le fichier `vault/secret.json`.

## Architecture

![alt text](https://storage.googleapis.com/shoru-project-0/architecture-actual.jpg)

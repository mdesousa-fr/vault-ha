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

## Execution
COMING SOON

## Architecture
COMING SOON

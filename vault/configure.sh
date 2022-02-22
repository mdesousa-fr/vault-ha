VAULT_LEADER_IP=$(sed '1!d' ansible/inventory)

# Initialize Vault leader
curl --request POST \
    --data '{"secret_shares": 1, "secret_threshold": 1}' \
    http://${VAULT_LEADER_IP}:8200/v1/sys/init | jq > vault/leader_secret.json

ROOT_TOKEN=$(cat vault/leader_secret.json | jq --raw-output '.root_token')

# Unseal Vault
UNSEAL_KEY_LEADER=$(cat vault/leader_secret.json | jq '.keys_base64[0]')
UNSEAL_DATA_LEADER=$(printf '{"key": %s}' ${UNSEAL_KEY_LEADER})
curl --request POST \
    --data "${UNSEAL_DATA_LEADER}" \
    http://${VAULT_LEADER_IP}:8200/v1/sys/unseal

export VAULT_ADDR="http://${VAULT_LEADER_IP}:8200"
export VAULT_TOKEN="${ROOT_TOKEN}"

vault login ${ROOT_TOKEN}

# Enable username authentication method
vault auth enable userpass

# Create production key/value engine
vault secrets enable -path=production kv

# Create production policy
vault policy write production_admin vault/policy.hcl

# Create demo user
vault write auth/userpass/users/demo password=password policies=production_admin

# Create a secret in production
vault kv put production/me message="Coucou"

# Login with userpass
vault login -method=userpass username=demo password=password

# Access to production secret
vault kv get production/me

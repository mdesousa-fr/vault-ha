VAULT_LEADER_IP=$(sed '1!d' ansible/inventory)
VAULT_FOLLOWER_1_IP=$(sed '2!d' ansible/inventory)
VAULT_FOLLOWER_2_IP=$(sed '3!d' ansible/inventory)
SECRET_FILE=vault/secret.json

echo "STAGE 1: Get Vault IP addresses"
echo "  - Vault leader: ${VAULT_LEADER_IP}"
echo "  - Vault follower 1: ${VAULT_FOLLOWER_1_IP}"
echo "  - Vault follower 2: ${VAULT_FOLLOWER_2_IP}"

# Initialize Vault leader
echo "STAGE 2: Initialize Vault leader"
export VAULT_ADDR="http://${VAULT_LEADER_IP}:8200"
if [ -f "${SECRET_FILE}" ]; then
    echo "  Secret file already exists"
    echo "  Skip initialization of Vault leader"
else
    echo "  Initialize..."
    vault operator init -key-shares=1 -key-threshold=1 -format=json > ${SECRET_FILE}
    sleep 5
fi
ROOT_TOKEN=$(cat ${SECRET_FILE} | jq --raw-output '.root_token')

# Unseal Vault leader
echo "STAGE 3: Unseal Vault leader"
UNSEAL_KEY_LEADER=$(cat ${SECRET_FILE} | jq --raw-output '.unseal_keys_b64[0]')
vault operator unseal ${UNSEAL_KEY_LEADER}
sleep 30

# Join Raft cluster
echo "STAGE 4: Joining Raft cluster"
echo "  - Joining follower 1..."
export VAULT_ADDR="http://${VAULT_FOLLOWER_1_IP}:8200"
vault operator raft join http://${VAULT_LEADER_IP}:8200
vault operator unseal ${UNSEAL_KEY_LEADER}

echo "  - Joining follower 2..."
export VAULT_ADDR="http://${VAULT_FOLLOWER_2_IP}:8200"
vault operator raft join http://${VAULT_LEADER_IP}:8200
vault operator unseal ${UNSEAL_KEY_LEADER}
sleep 5

echo "  - Checking Raft peers..."
export VAULT_ADDR="http://${VAULT_LEADER_IP}:8200"
export VAULT_TOKEN=${ROOT_TOKEN}
vault operator raft list-peers

echo "STAGE 5: Configure Vault"
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

echo "STAGE 6: Access Vault with demo user"
# Login with userpass
vault login -method=userpass username=demo password=password

# Access to production secret
vault kv get production/me

echo "Useful commands for more testing"
echo "=================================================="
echo "export VAULT_ADDR='http://${VAULT_LEADER_IP}:8200'"
echo "export VAULT_TOKEN='${ROOT_TOKEN}'"
echo "=================================================="

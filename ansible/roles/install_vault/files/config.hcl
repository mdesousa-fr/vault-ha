storage "raft" {
  path    = "/mnt/vault/data"
  node_id = "__SERVER_NAME__"
}

listener "tcp" {
  address     = "__SERVER_PRIVATE_IP__:8200"
  tls_disable = "true"
}

api_addr = "http://__SERVER_PUBLIC_IP__:8200"
cluster_addr = "https://__SERVER_PRIVATE_IP__:8201"
ui = true

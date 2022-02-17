project_id = "shoru-project"
region = "us-central1"
zone = "us-central1-a"
zones = [
   "us-central1-a",
   "us-central1-b",
   "us-central1-c",
]

machine_type = "e2-micro"
image = "debian-cloud/debian-10"

subnetwork_ip_cidr_range = "10.10.0.0/24"
ssh_public_key_file = "../keys/id_rsa.pub"
gcp_ssh_user = "m_desousa69150"

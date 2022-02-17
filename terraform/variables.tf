variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "zones" {
    type = list(string)
}

variable "machine_type" {
  type = string
  default = "e2-small"
}

variable "image" {
  type = string
  default = "debian-cloud/debian-10"
}

variable "subnetwork_ip_cidr_range" {
    type = string
}

variable "ssh_public_key_file" {
    type = string
}

variable "gcp_ssh_user" {
    type = string
}

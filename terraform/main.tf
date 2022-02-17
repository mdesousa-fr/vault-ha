terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "4.10.0"
        }
    }
    backend "gcs" {
        bucket = "shoru-project-0"
        prefix = "terraform/state"
    }
}

provider "google" {
    project = var.project_id
    region = var.region
}

resource "google_compute_instance" "vault-server" {
    for_each = toset(var.zones)
    name = "vault-server-${each.key}"
    machine_type = var.machine_type
    zone = each.key
    metadata = {
        ssh-keys = "${var.gcp_ssh_user}:${file(var.ssh_public_key_file)}"
    }
    boot_disk {
        initialize_params {
        image = var.image
        }
    }
    attached_disk {
        source = google_compute_disk.vault-disk[each.key].self_link
        mode = "READ_WRITE"
    }
    network_interface {
        network = google_compute_network.vault-network.self_link
        subnetwork = google_compute_subnetwork.vault-subnetwork.self_link
        access_config {
            nat_ip = google_compute_address.vault-static-ip[each.key].address
        }
    }
    allow_stopping_for_update = true
}

resource "google_compute_disk" "vault-disk" {
    for_each = toset(var.zones)
    name = "vault-disk-${each.key}"
    zone = each.key
    size = 10
}

resource "google_compute_network" "vault-network" {
    name = "vault-network"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vault-subnetwork" {
    name = "vault-subnetwork"
    ip_cidr_range = var.subnetwork_ip_cidr_range
    network = google_compute_network.vault-network.self_link
    region = var.region
    private_ip_google_access = true
}

resource "google_compute_address" "vault-static-ip" {
    for_each = toset(var.zones)
    name = "vault-static-ip-${each.key}"
}

resource "google_compute_firewall" "vault-firewall" {
    name = "vault-firewall"
    network = google_compute_network.vault-network.self_link
    source_ranges = [ "0.0.0.0/0" ]
    allow {
        protocol = "tcp"
        ports = [ "80", "8080", "443", "22" ]
    }
}

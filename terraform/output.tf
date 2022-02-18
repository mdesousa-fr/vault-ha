output "instances-static-ip" {
    value = [
        for zone in var.zones : "${google_compute_instance.vault-server[zone].name}: ${google_compute_address.vault-static-ip[zone].address}"
    ]
}

output "ansible-inventory" {
    value = [
        for zone in var.zones : google_compute_address.vault-static-ip[zone].address
    ]
}

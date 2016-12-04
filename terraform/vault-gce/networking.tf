resource "google_compute_network" "default" {
  name       = "vault"
}

resource "google_compute_subnetwork" "default-us-east1" {
  name          = "vault-us-east1"
  ip_cidr_range = "10.200.0.0/16"
  network       = "${google_compute_network.default.self_link}"
  region        = "us-east1"
}

resource "google_compute_address" "vault" {
  name = "vault"
}

resource "google_compute_firewall" "default" {
  name    = "test"
  network = "${google_compute_network.default.name}"


  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8200"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_dns_record_set" "vault" {
  name = "vault.${var.domainname}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.zonename}"

  rrdatas = ["${google_compute_address.vault.address}"]
}

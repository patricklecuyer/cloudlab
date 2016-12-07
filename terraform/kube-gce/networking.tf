resource "google_compute_network" "kube" {
  name       = "kube"
}

resource "google_compute_subnetwork" "default-us-east1" {
  name          = "default-us-east1"
  ip_cidr_range = "10.200.0.0/16"
  network       = "${google_compute_network.default.self_link}"
  region        = "us-east1"
}

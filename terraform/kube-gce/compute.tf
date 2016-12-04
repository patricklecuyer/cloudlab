resource "google_compute_instance" "master" {

  name         = "kube-master"
  machine_type = "g1-small"
  zone         = "us-east1-a"

  disk {
   type    = "local-ssd"
   scratch = true
 }
}

network_interface {
   network = "${google_compute_network.kube.name}"
   access_config {
     // Ephemeral IP
   }
 }

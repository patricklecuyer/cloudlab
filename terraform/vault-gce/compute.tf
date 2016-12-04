resource "google_compute_instance" "master" {

  name         = "vault"
  machine_type = "f1-micro"
  zone         = "us-east1-c"

  disk {
   type    = "pd-standard"
   image = "coreos-beta-1235-1-0-v20161130"
  }

 disk {
   disk = "${google_compute_disk.vault-db.name}"
   device_name = "vaultdb"
   auto_delete = false
 }

 metadata{
   user-data = "${data.template_file.vault-cloudinit.rendered}"
   }

network_interface {
   subnetwork = "${google_compute_subnetwork.default-us-east1.name}"
   access_config {
     nat_ip = "${google_compute_address.vault.address}"
   }
 }
}

 resource "google_compute_disk" "vault-db" {
   name  = "vault-db"
   type  = "pd-standard"
   zone  = "us-east1-c"
   size = 10

 }

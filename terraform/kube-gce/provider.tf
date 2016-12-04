// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.projectid}"
  region      = "us-east1"
}

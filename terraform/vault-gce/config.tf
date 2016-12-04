data "template_file" "vault-cloudinit" {
  template = "${file("vault-cloudinit.tpl.yaml")}"

  vars {
    hostname = "vault.${var.domainname}"
    email = "${var.email}"
  }
}

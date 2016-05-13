provider "azurerm" {

}

resource "azurerm_resource_group" "rg" {
  name     = "${var.envname}"
  location = "East US"

  tags {
    environment = "Lab"
  }
}

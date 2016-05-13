resource "azurerm_storage_account" "cloudlab-storage" {
    name = "cloudlab"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location = "eastus"
    account_type = "Standard_LRS"

    tags {
        environment = "lab"
    }
}

resource "azurerm_storage_container" "drives" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    storage_account_name = "${azurerm_storage_account.cloudlab-storage.name}"
    container_access_type = "private"
}

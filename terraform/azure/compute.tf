resource "azurerm_virtual_machine" "VM1" {
    name = "vm1"
    location = "East US"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${azurerm_network_interface.vm1.id}"]
    vm_size = "Standard_A0"

    storage_image_reference {
        publisher = "microsoftwindowsserver"
        offer = "WindowsServer"
        sku = "2016-Nano-Server-Technical-Preview"
        version = "latest"
    }

    storage_os_disk {
        name = "vm1disk1"
        vhd_uri = "${azurerm_storage_account.cloudlab-storage.primary_blob_endpoint}${azurerm_storage_container.drives.name}/vm1disk1.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "cloudlab-vm1"
        admin_username = "testadmin"
        admin_password = "Password1234!"
    }

}

resource "azurerm_virtual_machine" "vm2" {
    name = "vm2"
    location = "East US"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${azurerm_network_interface.vm2.id}"]
    vm_size = "Standard_A0"

    storage_image_reference {
        publisher = "microsoftwindowsserver"
        offer = "WindowsServer"
        sku = "2016-Nano-Server-Technical-Preview"
        version = "latest"
    }

    storage_os_disk {
        name = "vm2disk1"
        vhd_uri = "${azurerm_storage_account.cloudlab-storage.primary_blob_endpoint}${azurerm_storage_container.drives.name}/vm2disk1.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "cloudlab-vm2"
        admin_username = "testadmin"
        admin_password = "Password1234!"
    }



}

resource "azurerm_virtual_machine" "admin" {
    name = "admin"
    location = "East US"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${azurerm_network_interface.admin.id}"]
    vm_size = "Standard_A0"

    storage_image_reference {
          publisher = "Canonical"
          offer = "UbuntuServer"
          sku = "14.04.2-LTS"
          version = "latest"
      }

    storage_os_disk {
        name = "admindisk1"
        vhd_uri = "${azurerm_storage_account.cloudlab-storage.primary_blob_endpoint}${azurerm_storage_container.drives.name}/admin.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "cloudlab-admin2"
        admin_username = "testadmin"
        admin_password = "Password1234!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

}

resource "azurerm_virtual_network" "lab" {
  name                = "LabVirtualNetwork"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"

  subnet {
    name           = "Frontend"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "Backend"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name           = "admin"
    address_prefix = "10.0.3.0/24"
  }

  tags {
    environment = "lab"
  }
}


resource "azurerm_network_security_group" "frontend" {
    name = "acceptanceTestSecurityGroup1"
    location = "East US"
    resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_rule" "frontend-outbound" {
    name = "frontend-outbound"
    priority = 100
    direction = "Outbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.frontend.name}"
}

resource "azurerm_network_security_rule" "frontend-webinbound" {
    name = "web-inbound"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443:443"
    source_address_prefix = "*"
    destination_address_prefix = "10.0.1.0/24"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.frontend.name}"
}

resource "azurerm_network_security_rule" "frontend-internal" {
    name = "frontend-internal"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443:443"
    source_address_prefix = "*"
    destination_address_prefix = "10.0.0.0/16"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.frontend.name}"
}

resource "azurerm_network_security_group" "backend" {
    name = "acceptanceTestSecurityGroup1"
    location = "East US"
    resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_rule" "backend-outbound" {
    name = "backend-outbound"
    priority = 100
    direction = "Outbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.backend.name}"
}


resource "azurerm_network_security_rule" "backend-internal" {
    name = "backend-internal"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443:443"
    source_address_prefix = "*"
    destination_address_prefix = "10.0.0.0/16"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_name = "${azurerm_network_security_group.backend.name}"
}

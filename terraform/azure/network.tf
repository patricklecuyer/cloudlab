resource "azurerm_virtual_network" "lab" {
  name                = "LabVirtualNetwork"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"


  tags {
    environment = "lab"
  }
}


resource "azurerm_subnet" "frontend" {
  name           = "Frontend"
  resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.lab.name}"
  address_prefix = "10.0.1.0/24"
}

resource "azurerm_subnet" "backend" {
  name           = "backend"
  resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.lab.name}"
  address_prefix = "10.0.2.0/24"
}

resource "azurerm_subnet" "admin" {
  name           = "admin"
  resource_group_name = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.lab.name}"
  address_prefix = "10.0.3.0/24"
}



resource "azurerm_network_security_group" "frontend" {
    name = "frontend-secgroup"
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
    priority = 101
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
    name = "backend-secgroup"
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
    priority = 101
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


resource "azurerm_network_interface" "vm1" {
    name = "vm1"
    location = "East US"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name = "vm1"
        subnet_id = "${azurerm_subnet.frontend.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_network_interface" "vm2" {
    name = "vm2"
    location = "East US"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name = "vm2"
        subnet_id = "${azurerm_subnet.frontend.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_sql_firewall_rule" "database" {
    name = "FirewallRule1"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    server_name = "${azurerm_sql_server.sql1.name}"
    start_ip_address = "10.0.0.0"
    end_ip_address = "10.0.255.255"
}

resource "azurerm_network_interface" "admin" {
    name = "admin"
    location = "East US"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    ip_configuration {
        name = "vm1"
        subnet_id = "${azurerm_subnet.admin.id}"
        private_ip_address_allocation = "dynamic"
    }
}

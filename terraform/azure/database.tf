
resource "azurerm_sql_server" "sql1" {
    name = "cloudlabsql1"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location = "East US"
    version = "12.0"
    administrator_login = "mradministrator"
    administrator_login_password = "thisIsDog11"

    tags {
        environment = "lab"
    }
}

resource "azurerm_sql_database" "test" {
    name = "SQLDB"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    location = "East US"
    server_name = "${azurerm_sql_server.sql1.name}"

    tags {
        environment = "lab"
    }
}

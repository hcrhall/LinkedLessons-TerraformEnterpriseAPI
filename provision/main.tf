resource "azurerm_resource_group" "arm" {
  name     = "${var.azurerm_resource_group_name}"
  location = "${var.azurerm_resource_group_location}"
}

resource "azurerm_network_security_group" "arm" {
  name                = "SecurityGroup"
  location            = "${azurerm_resource_group.arm.location}"
  resource_group_name = "${azurerm_resource_group.arm.name}"
}

resource "azurerm_virtual_network" "arm" {
  name                = "VirtualNetwork"
  resource_group_name = "${azurerm_resource_group.arm.name}"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.arm.location}"
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "10.0.1.0_24"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "10.0.2.0_24"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name           = "10.0.3.0_24"
    address_prefix = "10.0.3.0/24"
    security_group = "${azurerm_network_security_group.arm.id}"
  }

  tags {
    Purpose = "PoC"
  }
}
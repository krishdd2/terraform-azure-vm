data "azurerm_virtual_network" "win-vm-iis-hermit-vnet" {
  name     = "win-vm-iis-hermit-vnet"
  resource_group_name  = "win-vm-iis-hermit-rg"
}
data "azurerm_subnet" "testing-snet" {
  name     = "win-vm-iis-hermit-subnet"
  virtual_network_name = "win-vm-iis-hermit-vnet"
  resource_group_name  = "win-vm-iis-hermit-rg"
}

resource "azurerm_resource_group" "testing-rg" {
  name     = "testing-rg"
  location = "East US"
}

resource "azurerm_network_security_group" "testing-nsg" {
  name                = "testing-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.testing-rg.name
}

resource "azurerm_network_security_rule" "testing-nsg" {
  name                        = "RDP"
  priority                    = 999
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.testing-rg.name
  network_security_group_name = azurerm_network_security_group.testing-nsg.name
}

resource "azurerm_network_interface" "testing-nic" {
  name                = "testing-nic"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.testing-rg.name

  ip_configuration {
    name                          = "testing-nic-ip"
    subnet_id                     = data.azurerm_subnet.testing-snet.id
    private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface_security_group_association" "testing-nsg-nic" {
  network_interface_id      = azurerm_network_interface.testing-nic.id
  network_security_group_id = azurerm_network_security_group.testing-nsg.id
}

resource "azurerm_virtual_machine" "testing-vm" {
  name                  = "testing-win10"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.testing-rg.name
  network_interface_ids = [azurerm_network_interface.testing-nic.id]
  vm_size               = "Standard_D2s_v3"
  storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-pro-g2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "testing-OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "testing-vm"
    admin_username = "testing-admin"
    admin_password = "P@$$w0rd1234!"
  }
  os_profile_windows_config {
    enable_automatic_upgrades = false
    provision_vm_agent        = true
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ee469ece-0f02-484b-b416-06ca8a570357"  # Updated with your new subscription ID
  resource_provider_registrations = "none"
}

# Create an Azure Resource Group
resource "azurerm_resource_group" "mo_resources" {
  name     = "mo-resources"
  location = "East US"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "mo_network" {
  name                = "mo-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mo_resources.location
  resource_group_name = azurerm_resource_group.mo_resources.name
}

# Create a Subnet
resource "azurerm_subnet" "mo_subnet" {
  name                 = "mo-subnet"
  resource_group_name  = azurerm_resource_group.mo_resources.name
  virtual_network_name = azurerm_virtual_network.mo_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a Network Interface
resource "azurerm_network_interface" "mo_nic" {
  name                = "mo-nic"
  location            = azurerm_resource_group.mo_resources.location
  resource_group_name = azurerm_resource_group.mo_resources.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mo_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a Virtual Machine
resource "azurerm_virtual_machine" "mo_vm" {
  name                  = "mo-vm"
  location              = azurerm_resource_group.mo_resources.location
  resource_group_name   = azurerm_resource_group.mo_resources.name
  network_interface_ids = [azurerm_network_interface.mo_nic.id]
  vm_size               = "Standard_DS1_v2"

  os_profile {
    computer_name  = "mo-host"
    admin_username = "mo-admin"
    admin_password = "Password123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name              = "mo-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

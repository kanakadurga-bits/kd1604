resource "azurerm_linux_virtual_machine" "appvm" {
  count = var.virtual_machine_count
  name                = "webvm0${count.index+1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "linuxadmin"
  admin_password = "Azure@123"
  disable_password_authentication = false
  network_interface_ids = [
    var.virtual_network_interface_ids[count.index]
  ]

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "datadisk" {
  count=var.virtual_machine_count
  name                 = "datadisk${count.index}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
  depends_on = [ azurerm_linux_virtual_machine.appvm ]
}
resource "azurerm_virtual_machine_data_disk_attachment" "datadisk_attachment" {
  count=var.virtual_machine_count
  managed_disk_id    = azurerm_managed_disk.datadisk[count.index].id
  virtual_machine_id = azurerm_virtual_machine.appvm[count.index].id
  lun                = "0"
  caching            = "ReadWrite"
}


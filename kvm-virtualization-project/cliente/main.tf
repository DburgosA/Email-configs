provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "client_disk" {
  name   = "client-disk.qcow2"
  pool   = "default"
  source = "${path.module}/../../isos/ubuntu-22.04-live-server-amd64.iso"
  size   = "20G"
}

resource "libvirt_domain" "client" {
  name   = var.client_name
  memory = var.memory
  vcpu   = var.cpu

  disk {
    volume_id = libvirt_volume.client_disk.id
  }

  network_interface {
    network_name = "default"
    addresses    = [var.client_ip]
  }

  cloudinit = file("${path.module}/cloud-init/user-data.yaml")
}

output "client_ip" {
  value = var.client_ip
}
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "server_disk" {
  name   = "server-disk.qcow2"
  pool   = "default"
  source = "path/to/your/image.qcow2" # Cambia esto por la ruta real de tu imagen
  size   = "20G"
}

resource "libvirt_domain" "server" {
  name   = var.server_hostname
  memory = var.memory
  vcpu   = var.cpu

  disk {
    volume_id = libvirt_volume.server_disk.id
  }

  network_interface {
    network_name = "default"
    addresses    = [var.server_ip]
  }

  cloudinit = file("${path.module}/cloud-init/user-data.yaml")
}

output "server_ip" {
  value = var.server_ip
}

# Ejemplo de instalación de cliente de correo en Linux
apt-get update
apt-get install -y thunderbird mutt
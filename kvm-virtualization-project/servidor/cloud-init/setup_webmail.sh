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

resource "null_resource" "install_roundcube" {
  provisioner "remote-exec" {
    inline = [
      "pkg install -y roundcube",
      "service apache24 restart"
    ]

    connection {
      type        = "ssh"
      host        = var.server_ip
      user        = "root"
      private_key = file(var.ssh_private_key)
    }
  }
}
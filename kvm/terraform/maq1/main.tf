
#--- GET ISO IMAGE

# Fetch the ubuntu image
resource "libvirt_volume" "os_image" {
  name = "${var.hostname}-os_image"
  pool = "pool"
  format = "qcow2"
}

resource "null_resource" "resize_volume" {
  provisioner "local-exec" {
    command = "sudo qemu-img resize ${libvirt_volume.os_image.id} ${var.diskSize}G"
  }

  depends_on = [libvirt_volume.os_image]
}

#--- CREATE VM
resource "libvirt_domain" "domain-maq1" {
  name = "${var.hostname}"
  memory = var.memoryMB
  vcpu = var.cpu

  disk {
    volume_id = libvirt_volume.os_image.id
  }

  network_interface {
    network_name = "maas"
  }

  network_interface {
    network_name = "privada"
  }

  boot_device {
    dev = ["network", "hd"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
  provisioner "local-exec" {
    command = "virsh destroy ${self.name}"
  }
}

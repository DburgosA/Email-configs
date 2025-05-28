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

# Crear red interna para correo
cat > mailnet.xml <<EOF
<network>
  <name>mailnet</name>
  <bridge name='virbr10' stp='on' delay='0'/>
  <ip address='192.168.50.1' netmask='255.255.255.0'/>
</network>
EOF

virsh net-define mailnet.xml
virsh net-start mailnet
virsh net-autostart mailnet
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

# Instalar BIND y Postfix en FreeBSD
pkg install -y bind916 postfix

# Configuración básica de zona DNS (ejemplo)
cat > /usr/local/etc/namedb/named.conf <<EOF
options {
    directory "/usr/local/etc/namedb";
    listen-on { any; };
    allow-query { any; };
};
zone "midominio.org" {
    type master;
    file "master/midominio.org.db";
};
EOF

# Archivo de zona ejemplo
mkdir -p /usr/local/etc/namedb/master
cat > /usr/local/etc/namedb/master/midominio.org.db <<EOF
\$TTL 86400
@   IN  SOA ns1.midominio.org. admin.midominio.org. (
        20240601 ; Serial
        3600     ; Refresh
        1800     ; Retry
        604800   ; Expire
        86400 )  ; Minimum
    IN  NS  ns1.midominio.org.
ns1 IN  A   192.168.50.10
mail IN  A  192.168.50.10
@   IN  MX 10 mail.midominio.org.
EOF

# Habilitar y arrancar servicios
sysrc named_enable=YES
service named start

sysrc postfix_enable=YES
service postfix start
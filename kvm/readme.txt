# Para habilitar las redes

virsh net-define maas.xml
virsh net-start maas

virsh net-define privada.xml
virsh net-start privada


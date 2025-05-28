Entiendo, entonces tienes MAAS y KVM instalados en el mismo equipo, y la conexión a KVM se realiza a través de `qemu:///system`. En este caso, puedes simplificar la configuración utilizando el tipo de energía **"Virsh"** en MAAS para controlar tus máquinas virtuales.

A continuación, te proporcionaré una guía paso a paso para configurar MAAS y permitir que controle tus máquinas virtuales mediante `virsh` en un entorno donde todo está en el mismo equipo.

---

### **1. Configurar Acceso SSH desde MAAS al Host Local (localhost)**

Aunque MAAS y KVM están en el mismo equipo, MAAS utiliza SSH para conectarse al host y ejecutar comandos `virsh`. Por lo tanto, necesitas configurar el acceso SSH desde el usuario que ejecuta MAAS al host local (es decir, a sí mismo).

**Paso 1:** Identificar el Usuario de MAAS

- MAAS generalmente se ejecuta bajo el usuario `maas`. Confirma esto ejecutando:
  ```bash
  ps aux | grep maas
  ```
  Busca procesos relacionados con MAAS para confirmar el usuario.

**Paso 2:** Generar Clave SSH para el Usuario de MAAS

- Si el usuario `maas` no tiene una clave SSH, créala:
  ```bash
  sudo -u maas ssh-keygen -t rsa -b 4096 -N '' -f /var/lib/maas/.ssh/id_rsa
  ```
  Esto genera una clave SSH sin contraseña para el usuario `maas`.

**Paso 3:** Autorizar la Clave SSH para Acceso a Localhost

- Añade la clave pública al archivo `authorized_keys` del usuario `maas`:
  ```bash
  sudo -u maas cat /var/lib/maas/.ssh/id_rsa.pub >> /var/lib/maas/.ssh/authorized_keys
  ```
- Asegúrate de que los permisos sean correctos:
  ```bash
  sudo chown -R maas:maas /var/lib/maas/.ssh
  sudo chmod 700 /var/lib/maas/.ssh
  sudo chmod 600 /var/lib/maas/.ssh/authorized_keys
  ```

**Paso 4:** Verificar Acceso SSH sin Contraseña

- Prueba que el usuario `maas` puede conectarse a localhost sin contraseña:
  ```bash
  sudo -u maas ssh -o StrictHostKeyChecking=no localhost "echo SSH exitoso"
  ```
  Si ves "SSH exitoso" sin que se te pida una contraseña, el acceso SSH está configurado correctamente.

### **2. Asegurar que el Usuario de MAAS Puede Ejecutar Comandos `virsh`**

**Paso 1:** Añadir el Usuario `maas` al Grupo `libvirt`

- Esto le permite al usuario `maas` ejecutar comandos `virsh`:
  ```bash
  sudo usermod -aG libvirt maas
  ```
- Después de añadir el usuario al grupo, es recomendable reiniciar la sesión o reiniciar el servicio MAAS para que los cambios surtan efecto.

**Paso 2:** Verificar que `virsh` Funciona para el Usuario `maas`

- Ejecuta un comando de prueba:
  ```bash
  sudo -u maas virsh list --all
  ```
  Deberías ver la lista de máquinas virtuales. Si hay algún error, puede ser necesario ajustar los permisos o verificar la instalación de `libvirt`.

### **3. Configurar el Nodo en MAAS**

Ahora, configura el nodo en MAAS para utilizar `virsh` como tipo de energía.

**Paso 1:** Acceder a la Interfaz Web de MAAS

- Ingresa a la interfaz web de MAAS en tu navegador.

**Paso 2:** Editar la Configuración de Energía del Nodo

- Navega al nodo que deseas controlar y haz clic en **"Edit"** (Editar).
- Ve a la pestaña **"Power Configuration"** (Configuración de Energía).

**Paso 3:** Configurar los Parámetros de Energía

- **Power Type** (Tipo de Energía): Selecciona `Virsh`.
- **Power Address** (Dirección de Energía): Usa `localhost` o `127.0.0.1`.
- **Power ID** (ID de Energía): Introduce el nombre exacto de la máquina virtual, por ejemplo, `vm_maas1`.
- **Power User** (Usuario de Energía): Introduce `maas`.
- **Power Pass** (Contraseña de Energía): Déjala en blanco, ya que estás usando autenticación por clave SSH.

**Paso 4:** Guardar los Cambios

- Haz clic en **"Save"** (Guardar) para aplicar la configuración.

### **4. Probar el Control de Energía desde MAAS**

Ahora que la configuración está completa, prueba que MAAS pueda controlar el estado de energía de la máquina virtual.

**Paso 1:** Encender la Máquina Virtual

- En la interfaz de MAAS, selecciona el nodo y haz clic en **"Start"** (Encender) o **"Commission"** (Comisionar).
- Observa si MAAS puede encender la máquina virtual exitosamente.

**Paso 2:** Verificar el Estado

- Puedes verificar el estado de la máquina virtual usando `virsh`:
  ```bash
  virsh list --all
  ```
  Deberías ver que la máquina virtual `vm_maas1` está en estado `running`.

**Paso 3:** Apagar la Máquina Virtual

- Desde MAAS, intenta apagar el nodo.
- Verifica nuevamente con `virsh` que la máquina virtual está en estado `shut off`.

### **5. Resolver Posibles Problemas**

**Problema 1:** MAAS No Puede Ejecutar Comandos `virsh`

- **Solución:** Asegúrate de que el usuario `maas` está en el grupo `libvirt` y tiene permisos para ejecutar `virsh`.
- Verifica que el socket de `libvirt` tiene los permisos correctos:
  ```bash
  ls -l /var/run/libvirt/libvirt-sock
  ```
  Debería ser accesible para el grupo `libvirt`.

**Problema 2:** Error de SSH al Conectarse a Localhost

- **Solución:** Asegúrate de que el usuario `maas` tiene su clave pública en `~/.ssh/authorized_keys`.
- Verifica que el demonio SSH está funcionando y permite conexiones a localhost.

**Problema 3:** MAAS Indica que No Puede Encontrar la Máquina Virtual

- **Solución:** Asegúrate de que el **Power ID** en MAAS coincide exactamente con el nombre de la máquina virtual en `virsh`.
  ```bash
  virsh list --all
  ```
  Usa el nombre que aparece en la lista.

### **6. Consideraciones Adicionales**

- **SELinux/AppArmor:** Si tienes SELinux o AppArmor habilitados, pueden bloquear las operaciones de `virsh`. Considera deshabilitarlos temporalmente para probar.
- **Firewall Local:** Asegúrate de que el firewall local no bloquea conexiones SSH a localhost (aunque no debería ser un problema).
- **Versiones de Software:** Asegúrate de que estás utilizando versiones compatibles de MAAS, `libvirt` y `virsh`.

### **7. Resumen de Pasos**

- Configurar acceso SSH sin contraseña desde el usuario `maas` a localhost.
- Añadir el usuario `maas` al grupo `libvirt` para permitirle ejecutar comandos `virsh`.
- Configurar el nodo en MAAS utilizando `virsh` como tipo de energía y `localhost` como dirección.
- Verificar que MAAS puede controlar el estado de energía de la máquina virtual.

---

### **Ejemplo de Comandos para Resumir la Configuración**

```bash
# Como root o usando sudo
# 1. Añadir el usuario maas al grupo libvirt
sudo usermod -aG libvirt maas

# 2. Generar clave SSH para el usuario maas
sudo -u maas ssh-keygen -t rsa -b 4096 -N '' -f /var/lib/maas/.ssh/id_rsa

# 3. Añadir clave pública al authorized_keys del usuario maas
sudo -u maas cat /var/lib/maas/.ssh/id_rsa.pub >> /var/lib/maas/.ssh/authorized_keys

# 4. Asegurar permisos correctos
sudo chown -R maas:maas /var/lib/maas/.ssh
sudo chmod 700 /var/lib/maas/.ssh
sudo chmod 600 /var/lib/maas/.ssh/authorized_keys

# 5. Verificar acceso SSH
sudo -u maas ssh -o StrictHostKeyChecking=no localhost "echo SSH exitoso"

# 6. Verificar acceso a virsh
sudo -u maas virsh list --all

# 7. Configurar el nodo en MAAS como se describe anteriormente
```

---

### **Notas Finales**

- **Seguridad:** Aunque estás configurando SSH a localhost, es importante mantener buenas prácticas de seguridad. Asegúrate de que los permisos de los archivos y directorios SSH son correctos.
- **Uso de Claves SSH:** Si por alguna razón prefieres no configurar SSH incluso a localhost, considera configurar MAAS para que utilice `sudo` para ejecutar `virsh` sin contraseña. Sin embargo, esto puede ser menos seguro y no es la práctica recomendada.
- **Documentación Adicional:** Puedes consultar la documentación oficial de MAAS sobre [cómo configurar el tipo de energía "Virsh"](https://maas.io/docs/supported-power-types#heading--virsh) para obtener más información.

---

Espero que esta guía detallada te ayude a configurar correctamente MAAS para controlar tus máquinas virtuales en KVM cuando todo está en el mismo equipo. Si tienes más preguntas o necesitas más asistencia, por favor, no dudes en preguntar.

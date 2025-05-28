# kvm-virtualization-project

## Objetivo

Este proyecto tiene como objetivo la creación de un entorno de virtualización utilizando KVM, Terraform y Cloud Init para configurar un servidor de correo y un cliente de correo. Se busca facilitar la comprensión de la lógica de configuración y funcionamiento de los servicios de correo electrónico, así como la implementación de servicios a nivel cliente-servidor en plataformas operativas Unix.

## Estructura del Proyecto

El proyecto está organizado en dos carpetas principales:

- **servidor**: Contiene la configuración para la máquina virtual del servidor, que incluye la configuración de red con una dirección IP fija y la automatización del proceso de instalación mediante Cloud Init.
  - `main.tf`: Configuración principal de Terraform para el servidor.
  - `variables.tf`: Definición de variables de entrada para la configuración del servidor.
  - `outputs.tf`: Especificación de los valores de salida de la configuración del servidor.
  - `cloud-init/user-data.yaml`: Configuración de Cloud Init para la automatización del servidor.

- **cliente**: Contiene la configuración para la máquina virtual del cliente, que se conectará al servidor de correo.
  - `main.tf`: Configuración principal de Terraform para el cliente.
  - `variables.tf`: Definición de variables de entrada para la configuración del cliente.
  - `outputs.tf`: Especificación de los valores de salida de la configuración del cliente.
  - `cloud-init/user-data.yaml`: Configuración de Cloud Init para la automatización del cliente.

## Instrucciones de Configuración

1. **Requisitos Previos**: Asegúrate de tener instalado KVM, Terraform y cualquier otra dependencia necesaria para la virtualización y la configuración de Cloud Init.

2. **Configuración del Servidor**:
   - Navega a la carpeta `servidor`.
   - Modifica el archivo `variables.tf` para establecer la dirección IP fija y otros parámetros necesarios.
   - Ejecuta `terraform init` para inicializar el proyecto.
   - Ejecuta `terraform apply` para crear la máquina virtual del servidor.

3. **Configuración del Cliente**:
   - Navega a la carpeta `cliente`.
   - Modifica el archivo `variables.tf` para establecer la dirección IP del servidor y otros parámetros necesarios.
   - Ejecuta `terraform init` para inicializar el proyecto.
   - Ejecuta `terraform apply` para crear la máquina virtual del cliente.

## Evaluación

La evaluación del proyecto se realizará mediante la entrega de un informe que documente el proceso de instalación, configuración y pruebas realizadas en el entorno de virtualización. Se sugiere incluir capturas de pantalla de los hitos más importantes del proceso.
variable "client_name" {
  description = "The name of the client virtual machine"
  type        = string
  default     = "cliente"
}

variable "client_ip" {
  description = "The fixed IP address for the client virtual machine"
  type        = string
}

variable "server_ip" {
  description = "The IP address of the server virtual machine"
  type        = string
}

variable "client_ssh_user" {
  description = "The SSH user for the client virtual machine"
  type        = string
  default     = "user"
}

variable "client_ssh_key" {
  description = "The SSH key for the client virtual machine"
  type        = string
}

variable "memory" {
  description = "The amount of memory for the client in MB"
  type        = number
  default     = 1024
}

variable "cpu" {
  description = "The number of CPUs for the client"
  type        = number
  default     = 1
}

variable "disk_size" {
  description = "The size of the disk for the client in GB"
  type        = number
  default     = 20
}
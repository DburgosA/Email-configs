variable "server_ip" {
  description = "The fixed IP address for the server"
  type        = string
}

variable "server_hostname" {
  description = "The hostname for the server"
  type        = string
  default     = "servidor"
}

variable "memory" {
  description = "The amount of memory for the server in MB"
  type        = number
  default     = 2048
}

variable "cpu" {
  description = "The number of CPUs for the server"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "The size of the disk for the server in GB"
  type        = number
  default     = 20
}

variable "os_image" {
  description = "Path to the OS image (FreeBSD for servidor, Linux for cliente)"
  type        = string
}
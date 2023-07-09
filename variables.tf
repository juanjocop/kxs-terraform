variable "cidr_block_vpc" {
  description = "cidr block for the subnet"
  default = "10.0.0.0/16"
  type = string
}

variable "cidr_block_subnet" {
  description = "cidr block for the subnet"
  default = "10.0.1.0/24"
  type = string
}

variable "aws_access_key" {
  description = "clave de acceso para aws"
  type = string
}

variable "aws_secret_key" {
  description = "secret key de aws"
  type = string
}

# variable "haproxy_cfg" {
#   description = "archivo de configuración para haproxy load balancer"
#   type = string
# }

#variable "aws_private_ip_range" {
#  description = "rango de ips privadas para nodos"
#  type = list(string)
#  default = ["10.0.1.100","10.0.1.101","10.0.1.102","10.0.1.103","10.0.1.104","10.0.1.105","10.0.1.106","10.0.1.107","10.0.1.108","10.0.1.109","10.0.1.110"]
#}
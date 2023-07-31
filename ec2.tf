resource "aws_network_interface" "interface_master" {
  # subnet_id = aws_subnet.kxs-subnet.id
  subnet_id = var.vpc_domotica_subnet_1
  #  private_ips = var.aws_private_ip_range
  security_groups = [aws_security_group.kxs-master-sg.id]
}

resource "aws_network_interface" "interface_worker_1" {
  # subnet_id = aws_subnet.kxs-subnet.id
  subnet_id = var.vpc_domotica_subnet_1
  #  private_ips = var.aws_private_ip_range
  security_groups = [aws_security_group.kxs-worker-sg.id]
}

resource "aws_network_interface" "interface_mariadb_1" {
  # subnet_id = aws_subnet.kxs-subnet.id
  subnet_id = var.vpc_domotica_subnet_1
  #  private_ips = var.aws_private_ip_range
  security_groups = [aws_security_group.kxs-mariadb-sg.id]
}

resource "aws_eip" "kxs_master_ip1" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.interface_master.id
  associate_with_private_ip = aws_network_interface.interface_master.private_ip
  # depends_on = [
  #   aws_internet_gateway.kxs-gateway,
  # ]
}

# resource "aws_eip" "kxs_worker_1_ip1" {
#   domain                    = "vpc"
#   network_interface         = aws_network_interface.interface_worker_1.id
#   associate_with_private_ip = aws_network_interface.interface_worker_1.private_ip
#   # depends_on = [
#   #   aws_internet_gateway.kxs-gateway,
#   # ]
# }

resource "aws_eip" "kxs_mariadb_1_ip1" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.interface_mariadb_1.id
  associate_with_private_ip = aws_network_interface.interface_mariadb_1.private_ip
  # depends_on = [
  #   aws_internet_gateway.kxs-gateway,
  # ]
}

# creacion de key pairs para kxs ec2 master
resource "tls_private_key" "kxs_ec2_master_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kxs_master_key" {
  key_name   = var.kxs_ec2_master_keyname
  public_key = tls_private_key.kxs_ec2_master_private_key.public_key_openssh
}

# creacion de key pairs para kxs ec2 worker
resource "tls_private_key" "kxs_ec2_worker_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kxs_worker_key" {
  key_name   = var.kxs_ec2_worker_keyname
  public_key = tls_private_key.kxs_ec2_worker_private_key.public_key_openssh
}

# creacion de key pairs para kxs ec2 mariadb
resource "tls_private_key" "kxs_ec2_mariadb_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kxs_mariadb_key" {
  key_name   = var.kxs_ec2_mariadb_keyname
  public_key = tls_private_key.kxs_ec2_mariadb_private_key.public_key_openssh
}

# creacion de ec2 para mastar kxs
resource "aws_instance" "kxs_master" {
  ami           = var.ami_kxs_arm
  instance_type = "t4g.micro"
  # availability_zone = aws_subnet.kxs-subnet.availability_zone
  availability_zone = var.availability_zone_1
  key_name          = aws_key_pair.kxs_master_key.key_name
  #  count = 2 para instancias clon

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.interface_master.id
  }

  #   provisioner "local-exec" {
  #     command = "echo '${self.public_ip}\n${self.private_ip}' > ips_${aws_instance.kxs_master.tags.Name}.txt"
  #   }

  provisioner "local-exec" {
    when    = destroy
    command = "rm ~/.ssh/kxs_master.pem"
  }

  tags = {
    "Name" = "kxs_master"
    "app"  = "kxs"
  }
  depends_on = [
    aws_eip.kxs_master_ip1
  ]

}

# Creación de las instancias EC2 workers

resource "aws_instance" "kxs_worker_1" {
  ami           = var.ami_kxs_arm
  instance_type = "t4g.medium"
  # availability_zone = aws_subnet.kxs-subnet.availability_zone
  availability_zone = var.availability_zone_1
  key_name          = aws_key_pair.kxs_worker_key.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.interface_worker_1.id
  }

  tags = {
    "Name" = "kxs_worker_1"
    "app"  = "kxs"
  }

  # depends_on = [
  #   aws_eip.kxs_worker_1_ip1
  # ]

  provisioner "local-exec" {
    when    = destroy
    command = "rm ~/.ssh/kxs_worker.pem"
  }
}
# Creación de las instancias EC2 Spot
# resource "aws_spot_instance_request" "spot_worker" {
#   ami                    = "ami-0e297b87964330763" # Cambia esto por la AMI que necesites
#   instance_type          = "t4g.medium"
#   subnet_id              = aws_subnet.kxs-subnet.id
#   key_name               = aws_key_pair.kxs_worker_key.key_name
#   vpc_security_group_ids = ["${aws_security_group.kxs-basic-traffic.id}"]
#   tags = {
#     "Name" = "kxs_aws_worker_1"
#     "app"  = "kxs"
#   }

#   wait_for_fulfillment = true
# }

## Creación de instancia MariaDB
resource "aws_instance" "kxs_mariadb" {
  ami           = var.ami_kxs_arm
  instance_type = "t4g.micro"
  # availability_zone = aws_subnet.kxs-subnet.availability_zone
  availability_zone = var.availability_zone_1
  key_name          = aws_key_pair.kxs_mariadb_key.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.interface_mariadb_1.id
  }

  root_block_device {
    volume_size           = 30 # Tamaño del volumen raíz en GiB
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    "Name" = "kxs_mariadb"
    "app"  = "kxs"
  }
  depends_on = [
    aws_eip.kxs_master_ip1
  ]

  provisioner "local-exec" {
    when    = destroy
    command = "rm ~/.ssh/kxs_mariadb.pem"
  }
}

resource "local_sensitive_file" "kxs_master_keypair" {
  content         = tls_private_key.kxs_ec2_master_private_key.private_key_pem
  filename        = "${var.ruta_keypairs}.ssh/kxs_master.pem"
  file_permission = "0600"
}

resource "local_sensitive_file" "kxs_worker_keypair" {
  content         = tls_private_key.kxs_ec2_worker_private_key.private_key_pem
  filename        = "${var.ruta_keypairs}.ssh/kxs_worker.pem"
  file_permission = "0600"
}

resource "local_sensitive_file" "kxs_mariadb_keypair" {
  content         = tls_private_key.kxs_ec2_mariadb_private_key.private_key_pem
  filename        = "${var.ruta_keypairs}.ssh/kxs_mariadb.pem"
  file_permission = "0600"
}

## IPS publicas de las instancias
output "ec2_kxs_master_public_ip" {
  value       = aws_instance.kxs_master.public_ip
  description = "Ip publica del master kxs"
}

output "ec2_kxs_worker_public_ip" {
  value       = aws_instance.kxs_worker_1.public_ip
  description = "Ip publica del worker1 kxs"
}

output "ec2_kxs_mariadb_public_ip" {
  value       = aws_instance.kxs_mariadb.public_ip
  description = "Ip publica del mariadb kxs"
}

## IPS privadas de las instancias
output "ec2_kxs_master_private_ip" {
  value       = aws_instance.kxs_master.private_ip
  description = "Ip privada del master kxs"
}

output "ec2_kxs_worker_private_ip" {
  value       = aws_instance.kxs_worker_1.private_ip
  description = "Ip privada del worker1 kxs"
}

output "ec2_kxs_mariadb_private_ip" {
  value       = aws_instance.kxs_mariadb.private_ip
  description = "Ip privada del mariadb kxs"
}

## DNS privados para comunicacion interna
output "ec2_kxs_master_private_dns" {
  value       = aws_instance.kxs_master.private_dns
  description = "DNS privado del master kxs"
}

output "ec2_kxs_worker_private_dns" {
  value       = aws_instance.kxs_worker_1.private_dns
  description = "DNS privado del worker1 kxs"
}

output "ec2_kxs_mariadb_private_dns" {
  value       = aws_instance.kxs_mariadb.private_dns
  description = "DNS privado del mariadb kxs"
}

resource "aws_network_interface" "interface_master" {
  subnet_id = aws_subnet.kxs-subnet.id
  #  private_ips = var.aws_private_ip_range
  security_groups = [aws_security_group.kxs-basic-traffic.id]

}

resource "aws_eip" "kxs_master_ip1" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.interface_master.id
  associate_with_private_ip = aws_network_interface.interface_master.private_ip
  depends_on = [
    aws_internet_gateway.kxs-gateway,
  ]
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

# creacion de key pairs para ekxs c2 master
resource "tls_private_key" "kxs_ec2_worker_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kxs_worker_key" {
  key_name   = var.kxs_ec2_worker_keyname
  public_key = tls_private_key.kxs_ec2_worker_private_key.public_key_openssh
}

# creacion de ec2 para mastar kxs
resource "aws_instance" "kxs_master" {
  ami               = "ami-0e297b87964330763"
  instance_type     = "t4g.micro"
  availability_zone = aws_subnet.kxs-subnet.availability_zone
  key_name          = aws_key_pair.kxs_master_key.key_name
  #  count = 2 para instancias clon

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.interface_master.id
  }

  #   provisioner "local-exec" {
  #     command = "echo '${self.public_ip}\n${self.private_ip}' > ips_${aws_instance.kxs_master.tags.Name}.txt"
  #   }

  #   provisioner "local-exec" {
  #     when    = destroy
  #     command = "rm ips_ubuntu-kxs_master.txt"
  #   }

  tags = {
    "Name" = "kxs_master"
    "app"  = "kxs"
  }
  depends_on = [
    aws_eip.kxs_master_ip1
  ]
}

# Creación de las instancias EC2 Spot
resource "aws_spot_instance_request" "spot_worker" {
  ami                    = "ami-0e297b87964330763" # Cambia esto por la AMI que necesites
  instance_type          = "t4g.medium"
  subnet_id              = aws_subnet.kxs-subnet.id
  key_name               = aws_key_pair.kxs_worker_key.key_name
  vpc_security_group_ids = ["${aws_security_group.kxs-basic-traffic.id}"]
  tags = {
    "Name" = "kxs_aws_worker_1"
    "app"  = "kxs"
  }

  wait_for_fulfillment = true
}

resource "local_file" "kxs_master_keypair" {
  sensitive_content = tls_private_key.kxs_ec2_master_private_key.private_key_pem
  filename          = "${path.module}/kxs_master.pem"
  file_permission   = "0600"
}

resource "local_file" "kxs_master_keypair" {
  sensitive_content = tls_private_key.kxs_ec2_worker_private_key.private_key_pem
  filename          = "${path.module}/kxs_worker.pem"
  file_permission   = "0600"
}

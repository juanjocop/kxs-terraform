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

# creacion de ec2 para mastar kxs
resource "aws_instance" "kxs_master" {
  ami               = "ami-0e297b87964330763"
  instance_type     = "t4g.micro"
  availability_zone = aws_subnet.kxs-subnet.availability_zone
  key_name          = "kxs-master"
  #  count = 2 para instancias clon

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.interface_master.id
  }

  provisioner "local-exec" {
    command = "echo '${self.public_ip}\n${self.private_ip}' > ips_${aws_instance.kxs_master.tags.Name}.txt"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm ips_ubuntu-kxs_master.txt"
  }

  tags = {
    "Name" = "ubuntu-kxs_master"
  }
  depends_on = [
    aws_eip.kxs_master_ip1
  ]
}

# Creación de las instancias EC2 Spot
resource "aws_spot_instance_request" "spot_worker" {
  count                  = 1                       # Cambia esto por el número de instancias Spot que necesites
  ami                    = "ami-0e297b87964330763" # Cambia esto por la AMI que necesites
  instance_type          = "t4g.medium"
  subnet_id              = aws_subnet.kxs-subnet.id
  vpc_security_group_ids = ["${aws_security_group.kxs-basic-traffic.id}"]

  wait_for_fulfillment = true
}

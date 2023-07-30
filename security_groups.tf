# security rules para k0s en solo un cluster en una nube dentro de una misma subnet

# resource "aws_security_group_rule" "HTTPS" {
#   type              = "ingress"
#   to_port           = 443
#   protocol          = "TCP"
#   from_port         = 443
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.kxs-basic-traffic.id
# }

# resource "aws_security_group_rule" "HTTP" {
#   type              = "ingress"
#   to_port           = 80
#   protocol          = "TCP"
#   from_port         = 80
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.kxs-basic-traffic.id
# }


## Masters Security Group
resource "aws_security_group_rule" "SSH_master" {
  type              = "ingress"
  to_port           = 22
  protocol          = "TCP"
  from_port         = 22
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kxs-master-sg.id
}

resource "aws_security_group_rule" "allow_all_master" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  security_group_id = aws_security_group.kxs-master-sg.id
}

resource "aws_security_group_rule" "api_server" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kxs-master-sg.id
}

resource "aws_security_group_rule" "flannel_master" {
  type              = "ingress"
  from_port         = 8472
  to_port           = 8472
  protocol          = "UDP"
  cidr_blocks       = [var.cidr_block_subnet]
  security_group_id = aws_security_group.kxs-master-sg.id
}

resource "aws_security_group_rule" "kubelet_metrics_master" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "TCP"
  cidr_blocks       = [var.cidr_block_subnet]
  security_group_id = aws_security_group.kxs-master-sg.id
}

resource "aws_security_group_rule" "flannel_ipv4_wg_master" {
  type              = "ingress"
  from_port         = 51820
  to_port           = 51820
  protocol          = "UDP"
  cidr_blocks       = [var.cidr_block_subnet]
  security_group_id = aws_security_group.kxs-master-sg.id
}

## Workers Security Group
resource "aws_security_group_rule" "SSH_worker" {
  type              = "ingress"
  to_port           = 22
  protocol          = "TCP"
  from_port         = 22
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kxs-worker-sg.id
}

resource "aws_security_group_rule" "allow_all_worker" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  security_group_id = aws_security_group.kxs-worker-sg.id
}

resource "aws_security_group_rule" "flannel_worker" {
  type              = "ingress"
  from_port         = 8472
  to_port           = 8472
  protocol          = "UDP"
  cidr_blocks       = [var.cidr_block_subnet]
  security_group_id = aws_security_group.kxs-worker-sg.id
}

resource "aws_security_group_rule" "kubelet_metrics_worker" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "TCP"
  cidr_blocks       = [var.cidr_block_subnet]
  security_group_id = aws_security_group.kxs-worker-sg.id
}

resource "aws_security_group_rule" "flannel_ipv4_wg_worker" {
  type              = "ingress"
  from_port         = 51820
  to_port           = 51820
  protocol          = "UDP"
  cidr_blocks       = [var.cidr_block_subnet]
  security_group_id = aws_security_group.kxs-worker-sg.id
}

## MariaDB security rules
resource "aws_security_group_rule" "SSH_mariadb" {
  type              = "ingress"
  to_port           = 22
  protocol          = "TCP"
  from_port         = 22
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kxs-mariadb-sg.id
}

resource "aws_security_group_rule" "mariadb_port" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  cidr_blocks       = [var.cidr_block_subnet]
  security_group_id = aws_security_group.kxs-mariadb-sg.id
}

resource "aws_security_group_rule" "mariadb_egress_vpc" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.cidr_block_subnet]
  security_group_id = aws_security_group.kxs-mariadb-sg.id
}


# resource "aws_security_group_rule" "k0s_etcd" {
#   type              = "ingress"
#   to_port           = 2380
#   protocol          = "TCP"
#   from_port         = 2380
#   cidr_blocks       = [var.cidr_block_subnet]
#   security_group_id = aws_security_group.kxs-basic-traffic.id
# }

# resource "aws_security_group_rule" "k0s_apiserver" {
#   type              = "ingress"
#   to_port           = 6443
#   protocol          = "TCP"
#   from_port         = 6443
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.kxs-basic-traffic.id
# }

# resource "aws_security_group_rule" "k0s_router" {
#   type              = "ingress"
#   to_port           = 179
#   protocol          = "TCP"
#   from_port         = 179
#   cidr_blocks       = [var.cidr_block_subnet]
#   security_group_id = aws_security_group.kxs-basic-traffic.id
# }

# resource "aws_security_group_rule" "k0s_calico" {
#   type              = "ingress"
#   to_port           = 4789
#   protocol          = "UDP"
#   from_port         = 4789
#   cidr_blocks       = [var.cidr_block_subnet]
#   security_group_id = aws_security_group.kxs-basic-traffic.id
# }

# resource "aws_security_group_rule" "k0s_kubelet" {
#   type              = "ingress"
#   to_port           = 10250
#   protocol          = "TCP"
#   from_port         = 10250
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.kxs-basic-traffic.id
# }

# resource "aws_security_group_rule" "k0s_api" {
#   type              = "ingress"
#   to_port           = 9443
#   protocol          = "TCP"
#   from_port         = 9443
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.kxs-basic-traffic.id
# }

# resource "aws_security_group_rule" "k0s_konnectserver" {
#   type              = "ingress"
#   to_port           = 8133
#   protocol          = "TCP"
#   from_port         = 8132
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.kxs-basic-traffic.id
# }

#resource "aws_security_group_rule" "k0s_metallbtcp" {
#  type              = "ingress"
#  to_port           = 7946
#  protocol          = "TCP"
#  from_port         = 7946
#  cidr_blocks = [ var.cidr_block_subnet ]
#  security_group_id = aws_security_group.kxs-basic-traffic.id
#}

#resource "aws_security_group_rule" "k0s_metallbudp" {
#  type              = "ingress"
#  to_port           = 7946
#  protocol          = "UDP"
#  from_port         = 7946
#  cidr_blocks = [ var.cidr_block_subnet ]
#  security_group_id = aws_security_group.kxs-basic-traffic.id
#}

# resource "aws_security_group_rule" "k0s_nodeports" {
#   type              = "ingress"
#   to_port           = 32767
#   protocol          = "TCP"
#   from_port         = 30000
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.kxs-basic-traffic.id
# }

# resource "aws_security_group_rule" "haproxy_dashboard" {
#   type              = "ingress"
#   to_port           = 9000
#   protocol          = "TCP"
#   from_port         = 9000
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.kxs-basic-traffic.id
# }

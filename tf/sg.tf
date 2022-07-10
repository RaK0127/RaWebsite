resource "aws_security_group" "server_sg" {
  description = "security group allowing server access"
  name        = "server sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow from vpn endpoints"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = concat(var.vpn_ipv4_cidr_blocks)
    ipv6_cidr_blocks = var.vpn_ipv6_cidr_blocks
  }

  ingress {
    description      = "Allow all from within security group"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    self             = true
  }

  egress {
	description      = "Allow all out"
	from_port        = 0
	to_port          = 0
	protocol         = "-1"
	cidr_blocks      = ["0.0.0.0/0"]
	ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    {
      "Env"  = terraform.workspace,
      "Name" = "Server Security Group"
    }
  )
}

resource "aws_security_group" "load_balancer_sg" {
  description = "load balancer security group access"
  name        = "load balancer sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow all from server security group"
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    security_groups = [aws_security_group.server_sg.id]
  }

  ingress {
    description      = "Allow port 443 access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow port 80 access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all out"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Env"  = terraform.workspace,
    "Name" = "ELB Security Group"
  }
}

resource "aws_key_pair" "aws-key" {
  key_name   = "aws-key"
  public_key = file(var.instance_pub_ssh_key)
}

resource "aws_instance" "nginx_server" {
  count         = var.instance_count
  ami           = data.aws_ami.Ubuntu.id
  instance_type = var.instance_type
  tags = {
    Name = "nginx_server"
  }
  # VPC
  subnet_id = element(module.vpc.public_subnets, count.index)
  # Security Group
  vpc_security_group_ids = [aws_security_group.server_sg.id]
  # the Public SSH key
  key_name = aws_key_pair.aws-key.id

  # nginx installation
  # storing the nginx.sh file in the EC2 instnace
  provisioner "file" {
    source      = var.bootstrap_script_path
    destination = "/tmp/nginx.sh"
  }

  # Exicuting the nginx.sh file
  # Terraform does not reccomend this method becuase Terraform state file cannot track what the scrip is provissioning
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nginx.sh",
      "sudo /tmp/nginx.sh"
    ]
  }
  # Setting up the ssh connection to install the nginx server
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.instance_private_ssh_key)
  }
}

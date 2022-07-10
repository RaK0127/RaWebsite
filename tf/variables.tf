variable "env" {
  type = string
  description = "the environment that is currently being deployed, this should be overwritten by the tfvars"
}

variable "vpc_cidr" {
  description = "The CIDR for the vpc"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "A list of availability zones to use for this region"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "A list of public subnet cidrs"
  type        = list(string)
  default     = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
}

variable "private_subnet_cidrs" {
  description = "A list of public subnet cidrs"
  type        = list(string)
  default     = ["10.0.64.0/20", "10.0.80.0/20", "10.0.96.0/20"]
}

variable "vpn_ipv4_cidr_blocks" {
  description = "allow access from the ipv4 vpn into the VPC"
  type        = list(string)
  default     = []
}

variable "vpn_ipv6_cidr_blocks" {
  description = "allow access from the ipv6 vpn into the VPC"
  type        = list(string)
  default     = []
}


variable "enable_dns_hostnames" {
  description = "boolean used to indicate whether or not to enable dns hostnames for new hosts"
  default     = true
}

variable "instance_count" {
  default = "3"
  description = "the number of ec2 instances (nginx servers) that should be running"
}

variable "instance_type" {
  description = "the instance type for the ec2 instances"
  default     = "t2.micro"
}

variable "aws_amis" {
  default = {
	us-east-1 = "ami-0f9cf087c1f27d9b1"
	eu-west-2 = "ami-095ed825090131933"
  }
}

variable "instance_pub_ssh_key" {
  description = "the path to the ssh pub key"
  default = "./ssh_key/id_rsa.pub"
}

variable "instance_private_ssh_key" {
  description = "the path to the ssh private key"
  default = "./ssh_key/id_rsa"
}

variable "bootstrap_script_path" {
  default = "./bootstrap/bootstrap.sh"
  description = "the path to the bootstrap script"
}

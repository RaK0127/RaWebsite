module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "sample-app"
  cidr = var.vpc_cidr

  azs            = var.availability_zones
  public_subnets = var.public_subnet_cidrs
  create_igw     = true

  enable_nat_gateway     = true
  one_nat_gateway_per_az = var.env == "prod" ? true : false
  single_nat_gateway     = var.env == "prod" ? false : true

  private_subnets      = var.private_subnet_cidrs
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    {
      "Env" = terraform.workspace,
      "Name" : "sample_app"
    }
  )
}

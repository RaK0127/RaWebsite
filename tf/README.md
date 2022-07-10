# Terraform Setup

Terraform will be used to manage the infrastructure. Terraform workspaces will be used to work with multiple environments.

# Overview
For this assignment, the approach is to setup a VPC which will contain public/private subnets, internet/nat gateway, security groups, ec2 instances, a load balancer.
Docker will be installed onto the ec2 instances in order to reduce dependencies for nginx, and to make the overall deployment much easier.

## VPC
In order to create the VPC, the terraform vpc module will be used. This is done in order to simplify the deployment, and allow us to focus on the resources
that are more important.
The following resources are created via this module:
1. VPC
2. Public/Private Subnets
3. Internet/nat gateway

## Webserver
For the website, a simple nginx server will be deployed. In a more production environment, ansible should be used to configure the ec2 instances, but for the purposes
of the assignment, the provisioner is used. The provisioner will install various dependencies (the most important being docker), and deploy the webserver.
The provisioner will create a html template and generate a random number, `$(shuf -i 0-1000 -n 1)`, this will be unique instances. Because HA is required,
there will be 3 instances in different subnets, each will display a unique number when we visit the ELB.

## ELB
An ELB needs to be created in order to route traffic to the various backends, this will have listeners to each of the ec2 instances.

Steps:
1. Export `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`
2. If the remote state is required, create the desired s3 bucket, e.g: `sample-app-bucket-terraform-state`, this needs to be unique across all aws accounts.
3. Update the vpn ip address to include your ip address
```terraform
variable "vpn_ipv4_cidr_blocks" {
  description = "allow access from the ipv4 vpn into the VPC"
  type        = list(string)
  default     = [
  	"your_ip_address/32"
  ]
}
```
3. Generate an ssh key within the `ssh_key` directory
4. Apply the terraform
```
terraform workspace new dev
terraform workspace select dev
terraform plan -var-file=./tfvars/dev.tfvars
terraform apply -var-file=./tfvars/dev.tfvars
```

# Notes
To create/switch across workspaces
```
terraform workspace new dev
terraform workspace select dev
```

Applying to dev environment
```
terraform workspace select dev
terraform plan -var-file=./tfvars/dev.tfvars
```

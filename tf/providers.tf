# create a terraform remote state on s3, this will allow our state to be stored remotely
terraform {
  backend "s3" {
	bucket = "sample-app-bucket-terraform-state"
	key    = "us-east-1.tfstate"
	region = "us-east-1"
  }
}

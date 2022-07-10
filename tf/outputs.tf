output "outputs" {
  value = {
	elb_host = aws_lb.sample_app.dns_name
  }
}

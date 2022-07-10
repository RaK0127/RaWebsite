resource "aws_lb" "sample_app" {
  name               = "sample-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = module.vpc.public_subnets

  tags = {
	"Env"  = terraform.workspace
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.sample_app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
	type             = "forward"
	target_group_arn = aws_lb_target_group.sample_app_http_tg.arn
  }
}

# setup an http target group, https would require a ssl cert
resource "aws_lb_target_group" "sample_app_http_tg" {
  name     = "sample-app-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

# attach the target group to each of the ec2 instances
resource "aws_lb_target_group_attachment" "sample_app_tg_attachment" {
  count = var.instance_count
  target_group_arn = aws_lb_target_group.sample_app_http_tg.arn
  target_id        = aws_instance.nginx_server[count.index].id
  port             = 80
}

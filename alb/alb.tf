resource "aws_lb" "alb" {
  name = "${var.prefix}-backend-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [var.alb_sg_id]
  subnets = ["${var.public_subnets[0]}", "${var.public_subnets[1]}"]
  enable_deletion_protection = false
}
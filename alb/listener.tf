resource "aws_lb_listener" "http_blue_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.blue_service_tg.arn
  }
}

resource "aws_lb_listener" "http_green_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = 8080
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.green_service_tg.arn
  }

}
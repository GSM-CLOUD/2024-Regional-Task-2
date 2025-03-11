resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code = 403
      content_type = "text/plain"
      message_body = "403 Forbidden"
    }
  }
}

resource "aws_lb_listener_rule" "service_rule" {
    listener_arn = aws_lb_listener.default.arn
    priority = 1

    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.service_tg.arn
    }

    condition {
      path_pattern {
        values = ["/api/*"]
      }
    }
  
}
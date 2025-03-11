resource "aws_lb_target_group" "blue_service_tg" {
    name = "${var.prefix}-blue-service-tg"
    port = 8080
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = var.vpc_id

    health_check {
      path = "/api/health"
      interval = 30
      timeout = 5
      healthy_threshold = 3
      unhealthy_threshold = 3 
    }

    tags = {
      Name = "${var.prefix}-blue-service-tg"
    }
}

resource "aws_lb_target_group" "green_service_tg" {
    name = "${var.prefix}-green-service-tg"
    port = 8080
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = var.vpc_id

    health_check {
      path = "/api/health"
      interval = 30
      timeout = 5
      healthy_threshold = 3
      unhealthy_threshold = 3 
    }

    tags = {
      Name = "${var.prefix}-green-service-tg"
    }
}
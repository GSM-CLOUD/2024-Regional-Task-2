output "blue_service_target_group_name" {
  value = aws_lb_target_group.blue_service_tg.name
}

output "green_service_target_group_arn" {
  value = aws_lb_target_group.green_service_tg.arn
}

output "blue_service_target_group_arn" {
  value = aws_lb_target_group.blue_service_tg.arn
}

output "green_service_target_group_name" {
  value = aws_lb_target_group.green_service_tg.name
}

output "blue_listener_arn" {
  value = aws_lb_listener.http_blue_listener.arn
}

output "green_listener_arn" {
  value = aws_lb_listener.http_green_listener.arn
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
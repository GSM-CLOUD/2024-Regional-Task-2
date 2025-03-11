output "backend_app_name" {
  value = aws_codedeploy_app.backend_app.name
}

output "backend_deployment_group_name" {
  value = aws_codedeploy_deployment_group.backend_app_dg.deployment_group_name
}
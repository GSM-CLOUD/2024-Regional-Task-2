resource "aws_codedeploy_app" "backend_app" {
  name             = "${var.prefix}-backend-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "backend_app_dg" {
  app_name = aws_codedeploy_app.backend_app.name
  deployment_group_name = "${var.prefix}-backend-dg"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
        termination_wait_time_in_minutes = 5
        action = "TERMINATE"
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.blue_listener_arn]
      }

      test_traffic_route {
        listener_arns = [var.green_listener_arn]
      }

      target_group {
        name = var.blue_service_target_group_name
      }

      target_group {
        name = var.green_service_target_group_name
      }
    }
  }
}
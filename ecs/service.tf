resource "aws_ecs_service" "service_service" {
    name = "${var.service_name}"
    cluster = aws_ecs_cluster.cluster.id
    task_definition = aws_ecs_task_definition.service_task_def.arn
    desired_count = 2
    launch_type = "FARGATE"

    network_configuration {
        subnets = ["${var.private_subnets[0]}", "${var.private_subnets[1]}"]
        security_groups = [var.service_sg_id]
        assign_public_ip = false
    }

    load_balancer {
      target_group_arn = var.service_target_group_arn
      container_name = "${var.container_name}"
      container_port = "${var.container_port}"
    }

    tags = {
      Name = "${var.service_name}"
    }
}
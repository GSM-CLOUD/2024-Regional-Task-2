resource "aws_ecs_task_definition" "service_task_def" {
    family = var.task_definition_name
    execution_role_arn = aws_iam_role.ecs_excution_role.arn
    task_role_arn = aws_iam_role.ecs_excution_role.arn
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = "512"
    memory = "1024"

    container_definitions = jsonencode([
        {
            name  = var.container_name
            image = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_backend_name}:latest"
            cpu   = 512
            memory = 1024
            essential = true
            portMappings = [
                {
                containerPort = var.container_port
                hostPort      = var.container_port
                }
            ]
        }
    ])

  tags = {
    Name = "${var.task_definition_name}"
  } 
}
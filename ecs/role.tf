resource "aws_iam_role" "ecs_excution_role" {
    name = "${var.ecs_task_execution_role_name}"

    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    })

    tags = {
      "Name" = "${var.ecs_task_execution_role_name}"
    }
}

resource "aws_iam_role_policy_attachment" "ecs_excution_policy_attach" {
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    role = aws_iam_role.ecs_excution_role.name
}
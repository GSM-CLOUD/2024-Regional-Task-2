resource "aws_ecr_repository" "ecr_backend" {
    name = "${var.prefix}-ecr-backend"
    image_tag_mutability = "MUTABLE"
    force_delete = true
    image_scanning_configuration {
      scan_on_push = true
    }

    tags = {
      "Name" = "${var.prefix}-ecr-backend"
    }
}
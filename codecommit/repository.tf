resource "aws_codecommit_repository" "backend_repository" {
  repository_name = "${var.prefix}-backend-code"

  default_branch = "main"

  tags = {
    Name = "${var.prefix}-backend-code"
  }
}
resource "aws_codecommit_repository" "frontend_repository" {
  repository_name = "${var.prefix}-frontend-code"

  default_branch = "main"

  tags = {
    Name = "${var.prefix}-frontend-code"
  }
}

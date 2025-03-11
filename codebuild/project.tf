resource "aws_codebuild_project" "backend_build" {
  name = "${var.prefix}-backend-build"
  build_timeout = "5"

  service_role = aws_iam_role.backend_build_role.arn

  source {
    type = "CODECOMMIT"
    location = var.backend_repo_clone_url_http
    git_clone_depth = 1
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:6.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild_logs.name
      stream_name = "${var.prefix}-backend-log-stream"
    }
  }
}
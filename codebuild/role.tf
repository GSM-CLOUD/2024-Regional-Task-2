data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "codebuild_ecr_policy" {
  name        = "${var.prefix}-codebuild-ecr-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "backend_build_role" {
  name               = "${var.prefix}-backend-build-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "codebuilddeveloper_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
  roles      = [aws_iam_role.backend_build_role.name]
  name = "${var.prefix}-backend-policy-attachment"
}

resource "aws_iam_policy_attachment" "cloudwatch_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  roles      = [aws_iam_role.backend_build_role.name]
  name = "${var.prefix}-backend-policy-attachment"
}

resource "aws_iam_policy_attachment" "codecommit_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
  roles      = [aws_iam_role.backend_build_role.name]
  name = "${var.prefix}-backend-policy-attachment"
}

resource "aws_iam_policy_attachment" "ecr_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
  roles      = [aws_iam_role.backend_build_role.name]
  name = "${var.prefix}-backend-policy-attachment"
}

resource "aws_iam_policy_attachment" "ecr_autorization_policy_attachment" {
  policy_arn = aws_iam_policy.codebuild_ecr_policy.arn
  roles      = [aws_iam_role.backend_build_role.name]
  name = "${var.prefix}-backend-policy-attachment"
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.prefix}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_role_policy_attachment" "codecommit_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
  role      = aws_iam_role.codepipeline_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
  role      = aws_iam_role.codepipeline_role.name
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role      = aws_iam_role.codepipeline_role.name
}

data "aws_iam_policy_document" "codepipeline_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::skills-codepipeline-artifacts-bucket",
      "arn:aws:s3:::skills-codepipeline-artifacts-bucket/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_s3_policy" {
  name   = "${var.prefix}-codepipeline-s3-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_s3_policy.json
}

data "aws_iam_policy_document" "codepipeline_codedeploy_policy" {
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:GetApplication",
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:StopDeployment"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline_codedeploy_policy" {
  name   = "${var.prefix}-codepipeline-codedeploy-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_codedeploy_policy.json
}

resource "aws_iam_policy" "ecs_register_task_definition_policy" {
  name        = "ECSRegisterTaskDefinitionPolicy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ecs:RegisterTaskDefinition"
        Effect   = "Allow"
        Resource = "arn:aws:ecs:${var.region}:${var.account_id}:task-definition/${var.task_definition_name}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.ecs_register_task_definition_policy.arn
}

resource "aws_iam_policy" "ecs_pass_role_policy" {
  name        = "ECSPassRolePolicy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = "arn:aws:iam::${var.account_id}:role/${var.ecs_task_execution_role_name}"
      }
    ]
  })
}




resource "aws_iam_role_policy_attachment" "codepipeline_role_pass_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.ecs_pass_role_policy.arn
}

resource "aws_iam_policy" "codedeploy_get_application_revision_policy" {
  name        = "CodeDeployGetApplicationRevisionPolicy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "codedeploy:GetApplicationRevision"
        Effect   = "Allow"
        Resource = "arn:aws:codedeploy:${var.region}:${var.account_id}:application:${var.backend_app_name}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_codedeploy_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codedeploy_get_application_revision_policy.arn
}

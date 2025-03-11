resource "aws_codepipeline" "backend_codepipeline" {
  name = "${var.prefix}-backend-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.bucket
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = var.backend_repo_name
        BranchName = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.backend_build_project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeployToECS"
      version = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ApplicationName = var.backend_app_name
        DeploymentGroupName = var.backend_deployment_group_name
        TaskDefinitionTemplateArtifact = "source_output"
        TaskDefinitionTemplatePath = "taskdef.json"
        AppSpecTemplateArtifact = "source_output"
        AppSpecTemplatePath = "appspec.yaml"
      }
    }
  }
}

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "${var.prefix}-codepipeline-artifacts-bucket"
}

resource "aws_codepipeline" "frontend_codepipeline" {
  name = "${var.prefix}-frontend-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.bucket
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = var.frontend_repo_name
        BranchName = "main"
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "S3"
      version = "1"
      input_artifacts = ["source_output"]
      configuration = {
        BucketName = var.frontend_bucket_name
        Extract = "true"
      }
    }
  }
}
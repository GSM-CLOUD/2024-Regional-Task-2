module "vpc" {
  source = "./vpc"
  prefix = var.prefix
  region = var.region
}

module "s3" {
  source = "./s3"
  prefix = var.prefix
  bucket_custom_prefix = var.bucket_custom_prefix

  depends_on = [ module.vpc ]
}

module "codecommit" {
  source = "./codecommit"
  prefix = var.prefix

  depends_on = [ module.s3 ]
}

module "ecr" {
  source = "./ecr"
  prefix = var.prefix
  
  depends_on = [ module.codecommit ]
}

module "ec2" {
  source = "./bastion"
  prefix = var.prefix
  public_subnets = module.vpc.public_subnets
  aws_ami = data.aws_ami.al2023_ami_amd.id
  vpc_id = module.vpc.vpc_id
  file_bucket_name = module.s3.file_bucket_name
  be_repo_name = module.codecommit.be_repo_name
  region = var.region
  account_id = data.aws_caller_identity.current.account_id
  ecr_backend_name = module.ecr.ecr_backend_name
  task_definition_name = var.task_definition_name
  container_name = var.container_name
  container_port = var.container_port
  fe_repo_name = module.codecommit.fe_repo_name
  private_subnets = module.vpc.private_subnets
  default_branch = var.default_branch
  ecs_task_execution_role_name = var.ecs_task_execution_role_name
  service_sg_id = module.vpc.service_sg_id

  depends_on = [ module.ecr ]
}

module "alb" {
  source = "./alb"
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id = module.vpc.alb_sg_id

}

module "ecs" {
  source = "./ecs"
  prefix = var.prefix
  cluster_name = var.cluster_name
  ecs_task_execution_role_name = var.ecs_task_execution_role_name
  task_definition_name = var.task_definition_name
  container_name = var.container_name
  account_id = data.aws_caller_identity.current.account_id
  region = var.region
  ecr_backend_name = module.ecr.ecr_backend_name
  container_port = var.container_port
  service_sg_id = module.vpc.service_sg_id
  private_subnets = module.vpc.private_subnets
  service_name = var.service_name
  blue_service_target_group_arn = module.alb.blue_service_target_group_arn

  depends_on = [ module.ec2 ]
}

module "codebuild" {
  source = "./codebuild"
  prefix = var.prefix
  backend_repo_clone_url_http = module.codecommit.backend_repo_clone_url_http

  depends_on = [ module.ecs ]  
}

module "codedeploy" {
  source = "./codedeploy"
  prefix = var.prefix
  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name
  blue_service_target_group_name = module.alb.blue_service_target_group_name
  green_service_target_group_name = module.alb.green_service_target_group_name
  blue_listener_arn = module.alb.blue_listener_arn
  green_listener_arn = module.alb.green_listener_arn

  depends_on = [ module.codebuild ]
}

module "codepipeline" {
  source = "./codepipline"
  prefix = var.prefix
  backend_repo_name = module.codecommit.be_repo_name
  backend_build_project_name = module.codebuild.backend_build_project_name
  backend_app_name = module.codedeploy.backend_app_name
  backend_deployment_group_name = module.codedeploy.backend_deployment_group_name
  account_id = data.aws_caller_identity.current.account_id
  region = var.region
  task_definition_name = var.task_definition_name
  ecs_task_execution_role_name = var.ecs_task_execution_role_name

  depends_on = [ module.codedeploy ]
}

module "cloudfront" {
  source = "./cloudfront"
  prefix = var.prefix
  alb_dns_name = module.alb.alb_dns_name
  s3_bucket_dns_name = module.s3.bucket_dns_name
  s3_bucket_name = module.s3.bucket_name

  depends_on = [ module.codepipeline ]
}
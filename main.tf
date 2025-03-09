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
  ecs_task_role_name = var.ecs_task_role_name

  depends_on = [ module.ecr ]
}

/*
module "ecs" {
  source = "./ecs"
  prefix = var.prefix
  cluster_name = var.cluster_name
  ecs_task_role_name = var.ecs_task_role_name

  depends_on = [ module.ec2 ]
}*/

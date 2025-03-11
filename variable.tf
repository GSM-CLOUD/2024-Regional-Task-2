variable "region" {
  default = "ap-northeast-2"
}

variable "awscli_profile" {
  default = "second-profile"
}

variable "prefix" {
  default = "skills"
}

variable "bucket_custom_prefix" {
  default = "gsm9"
}

variable "cluster_name" {
  default = "skills-ecs-cluster"
}

variable "service_name" {
  default = "backend"
}

variable "container_port" {
  default = 8080
}

variable "ecs_task_execution_role_name" {
    default = "skills-ecs-ecsTaskExecutionRole"
}

variable "task_definition_name" {
  default = "skills-task-definition"
}

variable "container_name" {
  default = "backend"
}

variable "default_branch" {
  default = "main"
}
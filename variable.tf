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

variable "task_definition_name" {
  default = "skills-task-definition"
}

variable "service_name" {
  default = "backend"
}

variable "container_name" {
  default = "backend"
}

variable "container_port" {
  default = 8080
}

variable "ecs_task_role_name" {
    default = "ecsTaskExecutionRole"
}
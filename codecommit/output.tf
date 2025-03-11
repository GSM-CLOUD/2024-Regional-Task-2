output "be_repo_name" {
  value = aws_codecommit_repository.backend_repository.repository_name
}

output "fe_repo_name" {
  value = aws_codecommit_repository.frontend_repository.repository_name
}

output "backend_repo_clone_url_http" {
  value = aws_codecommit_repository.backend_repository.clone_url_http
}
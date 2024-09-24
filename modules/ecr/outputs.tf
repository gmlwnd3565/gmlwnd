output "ecr_repository_uri" {
  value = local.ecr_exists ? data.aws_ecr_repository.existing_repo[0].repository_url : aws_ecr_repository.repo[0].repository_url
}
output "role" {
  value = aws_iam_role.github_actions.arn
}

output "bucket" {
  value = aws_s3_bucket.blog.id
}

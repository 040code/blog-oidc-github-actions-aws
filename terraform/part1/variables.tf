variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "github_actions_tls_certificate" {
  type    = string
  default = "https://token.actions.githubusercontent.com"
}

variable "principals" {
  type = list(string)
  default = ["arn:aws:iam::557218779171:user/niek"]
}

variable "repo" {
  description = "Format, org/repo. The repo will also used to create an s3 bukcet where the / is replaced by -."
  type = string
  default = "040code/blog-oidc-github-actions-aws"
}

variable "role" {
  type = object({
    name: string
    path: string
  })
  default = {
    name = "blog"
    path = "/github-actions/"
  }
}

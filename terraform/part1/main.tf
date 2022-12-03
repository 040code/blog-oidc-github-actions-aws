data "tls_certificate" "github_actions" {
  url = var.github_actions_tls_certificate
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = var.github_actions_tls_certificate
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.github_actions.certificates.*.sha1_fingerprint
}

data "aws_iam_policy_document" "github_actions_trusted_identity" {

  dynamic "statement" {
    for_each = length(var.principals) > 0 ? ["1"] : []
    content {
      actions = ["sts:AssumeRole"]
      principals {
        type        = "AWS"
        identifiers = var.principals
      }
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com", var.github_actions_tls_certificate]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.repo}:ref:refs/heads/main*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = var.role.name
  path               = var.role.path
  assume_role_policy = data.aws_iam_policy_document.github_actions_trusted_identity.json
}

resource "aws_iam_role_policy" "s3" {
  name   = "s3-policy"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.s3.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid = "1"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.blog.arn, "${aws_s3_bucket.blog.arn}*"
    ]
  }
}

resource "random_uuid" "main" {
}

resource "aws_s3_bucket" "blog" {
  bucket        = replace(var.repo, "/", "-")
  force_destroy = true
}

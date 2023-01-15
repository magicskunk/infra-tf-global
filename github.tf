resource "aws_iam_role" "github_actions" {
  name        = "github_actions_${var.organization_name}"
  description = "GitHub actions role used to interact with AWS via OIDC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RoleForGitHubActions",
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = ["repo:${var.organization_name}/*"]
          }
        }
      },
    ]
  })
}

resource "aws_iam_group" "admin" {
  name = "admin"
}

resource "aws_iam_group" "dev" {
  name = "dev"
}

data "aws_iam_policy" "admin_access" {
  name = "AdministratorAccess"
}

data "aws_iam_policy" "dev_access" {
  name = "ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "admin" {
  group      = aws_iam_group.admin.name
  policy_arn = data.aws_iam_policy.admin_access.arn
}

resource "aws_iam_group_policy_attachment" "admin_enforce_mfa" {
  group      = aws_iam_group.admin.name
  policy_arn = aws_iam_policy.enforce_mfa.arn
}

resource "aws_iam_group_policy_attachment" "dev" {
  group      = aws_iam_group.dev.name
  policy_arn = data.aws_iam_policy.dev_access.arn
}

resource "aws_iam_user" "user" {
  count         = length(var.user)
  name          = var.user[count.index].username
  force_destroy = true
}

resource "aws_iam_user_group_membership" "user" {
  count  = length(aws_iam_user.user)
  user   = aws_iam_user.user[count.index].name
  groups = var.user[count.index].groups
}

resource "aws_iam_user_login_profile" "user" {
  count                   = length(aws_iam_user.user)
  user                    = aws_iam_user.user[count.index].name
  password_reset_required = true
}

output "password" {
  value     = aws_iam_user_login_profile.user[*].password
  sensitive = true
}

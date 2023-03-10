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

data "aws_iam_policy" "allow_password_change" {
  name = "IAMUserChangePassword"
}

resource "aws_iam_account_password_policy" "account_password" {
  minimum_password_length        = 16
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
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
  # depends_on = [aws_iam_group.admin, aws_iam_group.dev]
  force_destroy = true
  tags          = {
    email = var.user[count.index].email
  }
}

resource "aws_iam_user_policy_attachment" "allow_password_change" {
  count      = length(aws_iam_user.user)
  user       = aws_iam_user.user[count.index].name
  policy_arn = data.aws_iam_policy.allow_password_change.arn
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

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
}

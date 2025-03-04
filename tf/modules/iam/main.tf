resource "aws_iam_user" "readonly_user" {
  name = var.iam_user_name
  path = "/"
}
resource "aws_iam_user_login_profile" "readonly_user_login" {
  user                    = aws_iam_user.readonly_user.name
  password_reset_required = false
  password_length         = 8
}

# Attach AWS managed ReadOnlyAccess policy
resource "aws_iam_user_policy_attachment" "readonly_policy" {
  user       = aws_iam_user.readonly_user.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

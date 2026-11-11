data "aws_iam_policy_document" "this" {
  # trust policy of the role
   statement {
    sid = "AllowDevelopersToAssume" # Sid (statement ID) is an identifier for a policy statement
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = ["arn:aws:iam::992382841893:user/alice"]  # the "alice" user must exist
      type = "AWS"
    }
    
  }
}

resource "aws_iam_role" "this" {
  name = "eks_developer"
  # to update the trust policy of this role we need iam:UpdateAssumeRolePolicy
  assume_role_policy = data.aws_iam_policy_document.this.json
}


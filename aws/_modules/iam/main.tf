

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_group_policy" "TerraFailIAM_group_policy" {
  name  = "TerraFailIAM_group_policy"
  group = aws_iam_group.TerraFailIAM_group.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowGroupToSeeBucketListInTheConsole",
        Action   = "S3:PutObject"
        Effect   = "Allow"
        Resource = "S3:*"
      },
    ]
  })
}

resource "aws_iam_group" "TerraFailIAM_group" {
  name = "TerraFailIAM_group"
  path = "/users/"
}

resource "aws_iam_role" "TerraFailIAM_role" {
  name = "TerraFailIAM_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "user@terrafail.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "TerraFailIAM_policy" {
  name_prefix = "TerraFailIAM_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "S3:PutObject"
        Resource = "S3:*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "TerraFailIAM_policy_attachment" {
  name       = "TerraFailIAM_policy_attachment"
  roles      = [aws_iam_role.TerraFailIAM_role.name]
  policy_arn = aws_iam_policy.TerraFailIAM_policy.arn
}

resource "aws_iam_role" "TerraFailIAM_role" {
  name = "TerraFailIAM_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "user@terrafail.com"

        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "TerraFailIAM_role_policy" {
  name = "TerraFailIAM_role_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "S3:PutObject"
        Resource = "S3:*"
      }
    ]
  })
  role = aws_iam_role.TerraFailIAM_role.name
}

resource "aws_iam_role" "TerraFailIAM_role_inline" {
  name = "TerraFailIAM_role_inline"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "user@terrafail.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "S3:PutObject"
          Resource = "S3:*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "TerraFailIAM_role_managed" {
  name = "TerraFailIAM_role_managed"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "user@terrafail.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_role" "TerraFailIAM_role_custom" {
  name = "TerraFailIAM_role_custom"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "user@terrafail.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [aws_iam_policy.TerraFailIAM_role_policy.arn]
}

resource "aws_iam_policy" "TerraFailIAM_role_policy_custom" {
  name_prefix = "TerraFailIAM_role_policy_custom"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "Lambda:InvokeFunction"
        Resource = "Lambda:*"
      }
    ]
  })
}

resource "aws_iam_user" "TerraFailIAM_user" {
  name = "TerraFailIAM_user"
  path = "/system/"
}

resource "aws_iam_user_policy" "TerraFailIAM_user_policy" {
  name = "TerraFailIAM_user_policyy"
  user = aws_iam_user.TerraFailIAM_user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "Lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = "Lambda:*"
      },
    ]
  })
}

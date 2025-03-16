# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Lambda@Edge redirect Stack - Terraform main.tf resource                                                                               ║
# ╠════════════════════════════════════╤═════════════════════════════════════════════════════╤═══════════════════════════════════════════════════════╣
# ║ lambda_policy                      │ aws_iam_policy                                      │ IAM Role for Lambda@Edge logs.                        ║
# ║ lambda_role                        │ aws_iam_role                                        │ IAM Role for Lambda@Edge.                             ║
# ║ attach                             │ aws_iam_role_policy_attachment                      │ Attach cwlogs policy attach to Lambda role.           ║
# ║ lambda_function                    │ aws_lambda_function                                 │ Lambda Function.                                      ║
# ╚════════════════════════════════════╧═════════════════════════════════════════════════════╧═══════════════════════════════════════════════════════╝

resource "aws_iam_policy" "lambda_policy" {
  name        = "iam-policy-for-lambdaedge-logs"
  description = "Managed Policy for Lambda@Edge about Logs."
  policy = templatefile("${path.module}/json/lambda-logs-policy.json", {
    Partition = var.partition,
    AccountId = var.accountid
  })
  tags = {
    Name = "iam-policy-for-lambdaedge-logs"
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "iam-role-for-lambdaedge"
  description        = "IAM Role For Lambda@Edge."
  assume_role_policy = file("${path.module}/json/lambda-trust-policy.json")
  tags = {
    Name = "iam-role-for-lambdaedge"
  }
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "lambda_function" {
  provider         = aws.global
  filename         = data.archive_file.lambda_code.output_path
  function_name    = "lambda-redirect"
  role             = aws_iam_role.lambda_role.arn
  handler          = "redirect.lambda_handler"
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
  runtime          = "python3.12"
  publish          = true
  tags = {
    Name = "lambda-redirect"
  }
}

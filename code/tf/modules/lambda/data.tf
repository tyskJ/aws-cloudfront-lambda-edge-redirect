# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Functions redirect Stack - Terraform data.tf data                                                                                     ║
# ╠═══════════════════════╤═══════════════════════════════════╤══════════════════════════════════════════════════════════════════════════════════════╣
# ║ lambda_code           │ archive_file                      │ Lambda source code.                                                                  ║
# ╚═══════════════════════╧═══════════════════════════════════╧══════════════════════════════════════════════════════════════════════════════════════╝

data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "./src/handlers/redirect/redirect.py"
  output_path = "./src/handlers/redirect/redirect.zip"
}

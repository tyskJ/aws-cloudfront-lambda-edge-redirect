provider "aws" {
  profile = "admin"
  region  = "ap-northeast-1"
}

provider "aws" {
  profile = "admin"
  region  = "us-east-1"
  alias   = "virginia"
}

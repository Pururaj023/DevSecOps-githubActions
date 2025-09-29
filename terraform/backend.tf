terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-2301"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"

    # Locking requires DynamoDB
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

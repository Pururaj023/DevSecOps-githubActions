terraform {
  backend "s3" {
    bucket        = "my-terraform-state-bucket-2301"
    key           = "env/prod/terraform.tfstate"
    region        = "us-east-1"
    encrypt       = true
    use_lockfile  = true     # enable native locking
  }
}

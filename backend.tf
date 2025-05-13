terraform {
//Імпорт стейту в S3 bucket
    backend "s3" {
    bucket = "my-terraform-state-bucket-alexmoroz-00001"
    key    = "terraform.tfstate"
    region = "eu-north-1"
    }
}
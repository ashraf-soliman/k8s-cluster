terraform {
  backend "s3" {
    bucket = "k8s-cluster80" 
    key    = "terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "k8s-cluster80"
  }
}


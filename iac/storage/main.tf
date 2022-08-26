provider "aws" {
  #version = "~> 2.28"  
  #region     = var.aws_region
  #access_key = var.aws_key
  #secret_key = var.aws_sec
}


module "s3" {
  source   = "app.terraform.io/CentenePoC/s3/aws"
  #aws_region = var.aws_region
  app_env   = var.app_env
  app_name   = var.app_name  
  app_id   = var.app_id    
  bucket_name = var.bucket_name
  repave_strategy = var.repave_strategy
}

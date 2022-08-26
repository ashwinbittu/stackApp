provider "aws" {
  #version = "~> 2.28"
  #region     = var.aws_region
}

data "terraform_remote_state" "network" {
  backend = "remote"
  config = {
    hostname = var.tf_host
    organization = var.tf_org 
    workspaces = {
      name = "${var.app_name}-${var.app_env}-${var.aws_region}-network"
    }
  }
}

module "launch-configuration" {
  source  = "app.terraform.io/CentenePoC/launch-configuration/aws"
  aws_ec2_keypair_name = data.terraform_remote_state.network.outputs.aws_ec2_keypair_name 
  aws_security_group_instances_id = data.terraform_remote_state.network.outputs.aws_security_group_instances_id  
  inst_type = var.inst_type
  aws_ebs_snap_id = var.aws_ebs_snap_id 
  aws_ebs_volume_size = var.aws_ebs_volume_size
  aws_ebs_volume_type = var.aws_ebs_volume_type
  inst_device_name = var.inst_device_name   
  repave_strategy = var.repave_strategy  
  app_version   = var.app_version   
  ami_owners   = var.ami_owners 
}


module "asg" {
  source  = "app.terraform.io/CentenePoC/asg/aws"
  aws_elb_name = data.terraform_remote_state.network.outputs.aws_elb_name
  aws_subnet_ids = data.terraform_remote_state.network.outputs.aws_subnet_ids  
  aws_launch_configuration_name = module.launch-configuration.aws_launch_configuration_name 
  repave_strategy = var.repave_strategy  
  app_env   = var.app_env
  app_name   = var.app_name  
  app_id   = var.app_id   
}
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

module "app-launch-template" {
  source  = "app.terraform.io/radammcorp/launchtemplate/aws"
  lt_name = var.lt_name  
  lt_description = var.lt_description  
  ami_id = var.ami_id  
  key_name = data.terraform_remote_state.network.outputs.aws_ec2_key-name 
  securitygroup_id = data.terraform_remote_state.network.outputs.aws_app_security_group_id  
  instance_type = var.instance_type
  instdevice_name = var.instdevice_name 
  user_datascript =  var.user_datascript  

  /*
  repave_strategy = var.repave_strategy  
  app_version   = var.app_version   
  ami_owners   = var.ami_owners 
  aws_ebs_snap_id = var.aws_ebs_snap_id 
  aws_ebs_volume_size = var.aws_ebs_volume_size
  aws_ebs_volume_type = var.aws_ebs_volume_type
  */

}

/*
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
*/
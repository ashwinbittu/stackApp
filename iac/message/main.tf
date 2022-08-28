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

module "message-launch-template" {
  source  = "app.terraform.io/radammcorp/launchtemplate/aws"
  lt_name = var.lt_name  
  lt_description = var.lt_description  
  ami_id = var.ami_id  
  key_name = data.terraform_remote_state.network.outputs.aws_ec2_key-name 
  securitygroup_id = data.terraform_remote_state.network.outputs.aws_message_security_group_id  
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

module "message-asg" {
  source  = "app.terraform.io/radammcorp/asg/aws"
  name = "message-asg"
  
  target_group_arns = data.terraform_remote_state.network.outputs.aws_message_alb_target_group_arns
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.aws_subnet_ids  

  launch_template_id = module.message-launch-template.launch_template_id
  launch_template_version = module.message-launch-template.launch_template_latest_version
  
  app_id   = var.app_id 
  app_name   = var.app_name 
  app_env   = var.app_env 
  repave_strategy = var.repave_strategy  
  layer = "cache"
  snsemail = "ashwin.bittu@gmail.com"

  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
    }
    triggers = ["desired_capacity"]
  }

  
  scaling_policies = {
      message-policy-1 = {
        policy_type = "TargetTrackingScaling"
        estimated_instance_warmup = 180 
        target_tracking_configuration = {
          predefined_metric_specification = {
            predefined_metric_type = "ASGAverageCPUUtilization"
          }
          target_value = 50.0
        }
      }
    }

}


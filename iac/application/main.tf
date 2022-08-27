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


module "asg" {
  source  = "app.terraform.io/radammcorp/asg/aws"
  name = "app-asg"
  
  load_balancers = data.terraform_remote_state.network.outputs.aws_elb_name
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.aws_subnet_ids  
  launch_template_name = module.app-launch-template.launch_template_name 
  
  repave_strategy = var.repave_strategy  
  layer = "app"
  snsemail = "ashwin.bittu@gmail.com"

  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  launch_template {
    id = module.app-launch-template.launch_template_id  
    version = module.app-launch-template.launch_template_latest_version 
  }

  instance_refresh {
      strategy = "Rolling"
      preferences {
        min_healthy_percentage = 50            
      }
      triggers = [ "desired_capacity" ] 
  }
   
  scaling_policies = {
      app-policy-1 = {
        policy_type = "TargetTrackingScaling"
        estimated_instance_warmup = 180 
        target_tracking_configuration = {
          predefined_metric_specification = {
            predefined_metric_type = "ASGAverageCPUUtilization"
            resource_label = "MyLabel"
          }
          target_value = 50.0
        }
      }
    }

}

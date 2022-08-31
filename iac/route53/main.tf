provider "aws" {
  #version = "~> 2.28"
  #region     = var.aws_region
}

data "aws_route53_zone" "selected" {
  name  = var.aws_route53_private_zone_name
  private_zone = true
}

data "aws_instances" "db-asg-instances" {
  instance_tags = {
    app_id   = var.app_id 
    app_name   = var.app_name 
    app_env   = var.app_env 
    layer = "database"
  }

  instance_state_names = ["running", "stopped"]
}


data "aws_instances" "cache-asg-instances" {
  instance_tags = {
    app_id   = var.app_id 
    app_name   = var.app_name 
    app_env   = var.app_env 
    layer = "cache"
  }

  instance_state_names = ["running", "stopped"]
}

data "aws_instances" "message-asg-instances" {
  instance_tags = {
    app_id   = var.app_id 
    app_name   = var.app_name 
    app_env   = var.app_env 
    layer = "message"
  }

  instance_state_names = ["running", "stopped"]
}



module "private-route53-records" {
  source = "app.terraform.io/radammcorp/route53-records/aws"
  #zone_name = var.aws_route53_private_zone_name
  zone_id = data.aws_route53_zone.selected.zone_id
  private_zone = true

  records = [ 
      {
        name = var.aws_route53_private_db_record
        full_name_override = true        
        type = "A"
        ttl     = "300"
        //records = ["10.1.1.1"]
        records = data.aws_instances.db-asg-instances.private_ips
      },
      {
        name = var.aws_route53_private_msg_record
        full_name_override = true        
        type = "A"
        ttl     = "300"
        records = data.aws_instances.message-asg-instances.private_ips
      },
      {
        name = var.aws_route53_private_cache_record
        full_name_override = true        
        type = "A"
        ttl     = "300"
        records = data.aws_instances.cache-asg-instances.private_ips
      }               
  ]

}


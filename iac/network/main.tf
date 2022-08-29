provider "aws" {
  #region     = var.aws_region
}

module "vpc" {
  source = "app.terraform.io/radammcorp/vpc/aws"
  #aws_region = var.aws_region
  no_of_subnets = var.no_of_subnets
  aws_vpc_cidr_block   = var.aws_vpc_cidr_block
  app_env   = var.app_env
  app_name   = var.app_name  
  app_id   = var.app_id  
  aws_vpc_instance_tenancy = var.aws_vpc_instance_tenancy
}

module "sg-alb" {
  source = "app.terraform.io/radammcorp/sg/aws"
  #aws_region = var.aws_region
  app_env   = var.app_env
  app_name   = var.app_name  
  app_id   = var.app_id    
  aws_vpc_id = module.vpc.aws_vpc_id
  name   = "sgalb"
  description = "security group for load balancer"

  ingress_with_cidr_blocks = [
      {
        rule = "https-443-tcp"
        cidr_blocks = "0.0.0.0/0"
      },  
      {
        rule = "http-80-tcp"
        cidr_blocks = "0.0.0.0/0"
      },         
  ]
}

module "sg-app" {
    source = "app.terraform.io/radammcorp/sg/aws"
    #aws_region = var.aws_region
    app_env   = var.app_env
    app_name   = var.app_name  
    app_id   = var.app_id      
    aws_vpc_id = module.vpc.aws_vpc_id
    name   = "sgapp"   
    description = "security group for application"

    computed_ingress_with_source_security_group_id = [
        {
          rule = "http-8080-tcp"
          source_security_group_id = module.sg-alb.security_group_id
        }        
      ]
    number_of_computed_ingress_with_source_security_group_id = 1
      
  }

module "sg-db" {
    source = "app.terraform.io/radammcorp/sg/aws"
    #aws_region = var.aws_region
    app_env   = var.app_env
    app_name   = var.app_name  
    app_id   = var.app_id      
    aws_vpc_id = module.vpc.aws_vpc_id
    name   = "sgdb"   
    description = "security group for database"
    computed_ingress_with_source_security_group_id = [
        {
          rule = "mysql-tcp"
          source_security_group_id = module.sg-app.security_group_id
        }       
      ]
    number_of_computed_ingress_with_source_security_group_id = 1  
}  

module "sg-cache" {
    source = "app.terraform.io/radammcorp/sg/aws"
    #aws_region = var.aws_region
    app_env   = var.app_env
    app_name   = var.app_name  
    app_id   = var.app_id      
    aws_vpc_id = module.vpc.aws_vpc_id
    name   = "sgcache"   
    description = "security group for cache"
    computed_ingress_with_source_security_group_id = [
        {
          rule = "memcached-tcp"
          source_security_group_id = module.sg-app.security_group_id
        }       
      ]
    number_of_computed_ingress_with_source_security_group_id = 1      
} 

module "sg-message" {
    source = "app.terraform.io/radammcorp/sg/aws"
    #aws_region = var.aws_region
    app_env   = var.app_env
    app_name   = var.app_name  
    app_id   = var.app_id      
    aws_vpc_id = module.vpc.aws_vpc_id
    name   = "sgmessage"   
    description = "security group for messaging"
    computed_ingress_with_source_security_group_id = [
        {
          rule = "rabbitmq-5672-tcp"
          source_security_group_id = module.sg-app.security_group_id
        }        
      ]
    number_of_computed_ingress_with_source_security_group_id = 1      
} 

module "ec2key" {
  source = "app.terraform.io/radammcorp/ec2-key/aws"
	key_name   = var.key_name
  app_env   = var.app_env
  app_name   = var.app_name  
  app_id   = var.app_id   
}

module "alb-front" {
  source  = "app.terraform.io/radammcorp/alb/aws"
  
  app_env   = var.app_env
  app_name   = var.app_name  
  app_id   = var.app_id 
  
  name = "albfront"
  load_balancer_type = "application"
  vpc_id             = module.vpc.aws_vpc_id
  subnets            = module.vpc.aws_subnet_ids
  security_groups    = [module.sg-alb.security_group_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:acm:ap-southeast-2:043042377913:certificate/6ea053c3-1ba9-42d7-aa59-6794656260a6"
      target_group_index = 0
      action_type        = "forward"
    }
  ]

  target_groups = [
    {
      name      = "tgapp"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/login"
        port                = "8080"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }      
    }
  ]

}


module "alb-db" {
  source  = "app.terraform.io/radammcorp/alb/aws"
  
  app_env   = var.app_env
  app_name   = var.app_name  
  app_id   = var.app_id 
  
  name = "albdb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.aws_vpc_id
  subnets            = module.vpc.aws_subnet_ids
  security_groups    = [module.sg-db.security_group_id]

  /*http_tcp_listeners = [
    {
      port               = 3306
      protocol           = "TCP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]*/

  target_groups = [
    {
      name      = "tgdb"
      backend_protocol = "TCP"
      backend_port     = 3306
      target_type      = "instance"     
    }
  ]

}

module "alb-cache" {
  source  = "app.terraform.io/radammcorp/alb/aws"
  
  app_env   = var.app_env
  app_name   = var.app_name  
  app_id   = var.app_id 
  
  name = "albcache"
  load_balancer_type = "application"
  vpc_id             = module.vpc.aws_vpc_id
  subnets            = module.vpc.aws_subnet_ids
  security_groups    = [module.sg-cache.security_group_id]

  /*http_tcp_listeners = [
    {
      port               = 11211
      protocol           = "TCP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]*/

  target_groups = [
    {
      name      = "tgcache"
      backend_protocol = "TCP"
      backend_port     = 11211
      target_type      = "instance"    
    }
  ]

}

module "alb-message" {
  source  = "app.terraform.io/radammcorp/alb/aws"
  
  app_env   = var.app_env
  app_name   = var.app_name  
  app_id   = var.app_id 
  
  name = "albmessage"
  load_balancer_type = "application"
  vpc_id             = module.vpc.aws_vpc_id
  subnets            = module.vpc.aws_subnet_ids
  security_groups    = [module.sg-message.security_group_id]

  /*http_tcp_listeners = [
    {
      port               = 5672
      protocol           = "TCP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]*/

  target_groups = [
    {
      name      = "tgmessage"
      backend_protocol = "TCP"
      backend_port     = 5672
      target_type      = "instance"     
    }
  ]

}


/*

#data "aws_route53_zone" "selected" {
#  name         = var.aws_route53_zone_name
#  #private_zone = false
#}

#module "route53" {
#  source = "app.terraform.io/radammcorp/route53/aws"
#  aws_region = var.aws_region
#  app_env   = var.app_env
#  app_name  = var.app_name  
#  app_id   = var.app_id  
#  aws_route53_zone_id = data.aws_route53_zone.selected.zone_id
#  aws_route53_record_name = var.aws_route53_record_name

#  # Adding to "dulastack." needs to be revied with service owner 
#  #aws_elb_dns_name = var.aws_elb_dns_name == "" ? "dummy-elb.us-east-1.elb.amazonaws.com" : "dualstack.${var.aws_elb_dns_name}"
#  aws_elb_dns_name = module.elb.aws_elb_dns_name #"dualstack.${module.elb.aws_elb_dns_name}"

#  # Passing defalut us-east-1 zone id to avoid apply error, logic needs to change later 
#  #aws_elb_zone_id = var.aws_elb_zone_id == "" ? "Z35SXDOTRQ7X7K" : var.aws_elb_zone_id
#  aws_elb_zone_id = module.elb.aws_elb_zone_id


#  repave_strategy = var.repave_strategy 
#  aws_route53_zone_name = var.aws_route53_zone_name
#  aws_vpc_id = module.vpc.aws_vpc_id
#}

*/





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

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.aws_vpc_id 
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
      }        
  ]

  ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = -1
      source_security_group_id = data.aws_security_group.default.id
    }        
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
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

    computed_egress_with_source_security_group_id = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        source_security_group_id = module.sg-alb.security_group_id
      }          
    ]

    number_of_computed_egress_with_source_security_group_id = 1      
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
     
    computed_egress_with_source_security_group_id = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          source_security_group_id = module.sg-app.security_group_id
        }       
      ]

    number_of_computed_egress_with_source_security_group_id = 1
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

    computed_egress_with_source_security_group_id = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          source_security_group_id = module.sg-app.security_group_id
        }       
      ]
          
    number_of_computed_egress_with_source_security_group_id = 1         
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


    computed_egress_with_source_security_group_id = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          source_security_group_id = module.sg-app.security_group_id
        }       
      ]
          
    number_of_computed_egress_with_source_security_group_id = 1        
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

data "aws_route53_zone" "selected" {
  name  = var.aws_route53_public_zone_name
}

module "public-route53" {
  source = "app.terraform.io/radammcorp/route53/aws"
 
  app_env   = var.app_env
  app_name  = var.app_name  
  app_id   = var.app_id
  
  createzone = false
  createrecord = true

  zone_id = data.aws_route53_zone.selected.zone_id
  zone_name =  data.aws_route53_zone.selected.zone_name

  records = [ 
      {
        name = var.aws_route53_public_record_name
        full_name_override = true
        type = "A"
        alias = {
          name    = module.alb-front.lb_dns_name
          zone_id = module.alb-front.lb_zone_id
        }
      }
  ]
  vpc_id = module.vpc.aws_vpc_id
}

module "private-route53" {
  source = "app.terraform.io/radammcorp/route53/aws"
  
  app_env   = var.app_env
  app_name  = var.app_name  
  app_id   = var.app_id  

  createzone = true
  createrecord = false
  zone_name = var.aws_route53_private_zone_name
  full_name_override = true 
  vpc_id = module.vpc.aws_vpc_id
}



/*

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

  http_tcp_listeners = [
    {
      port               = 3306
      protocol           = "TCP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]

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

  http_tcp_listeners = [
    {
      port               = 11211
      protocol           = "TCP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]

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

  http_tcp_listeners = [
    {
      port               = 5672
      protocol           = "TCP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]

  target_groups = [
    {
      name      = "tgmessage"
      backend_protocol = "TCP"
      backend_port     = 5672
      target_type      = "instance"     
    }
  ]

}


*/







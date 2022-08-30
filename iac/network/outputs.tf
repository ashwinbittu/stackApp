output "aws_vpc_id" {
  value = module.vpc.aws_vpc_id
}

output "aws_subnet_ids" {
  value = module.vpc.aws_subnet_ids
}

output "aws_gw_id" {
  value = module.vpc.aws_gw_id
}


output "aws_ec2_key-name" {
  value = module.ec2key.key-name
}

output "combined_key_details_visible" {
  value = tomap({"key-name" = module.ec2key.key-name, "private-key" = nonsensitive(module.ec2key.private_key), "public-key" = module.ec2key.public_key})
}


output "combined_key_details_hidden" {
  sensitive = true
  value = tomap({ "key-name" = module.ec2key.key-name, "private-key" = module.ec2key.private_key, "public-key" = module.ec2key.public_key })
}


output "aws_alb_security_group_id" {
  value = module.sg-alb.security_group_id
}

output "aws_alb_security_group_instance_name" {
  value = module.sg-alb.security_group_name
}

output "aws_app_security_group_id" {
  value = module.sg-app.security_group_id
}

output "aws_app_security_group_instance_name" {
  value = module.sg-app.security_group_name
}

output "aws_cache_security_group_id" {
  value = module.sg-cache.security_group_id
}

output "aws_cache_security_group_instance_name" {
  value = module.sg-cache.security_group_name
}

output "aws_db_security_group_id" {
  value = module.sg-db.security_group_id
}

output "aws_db_security_group_instance_name" {
  value = module.sg-db.security_group_name
}

output "aws_message_security_group_id" {
  value = module.sg-message.security_group_id
}

output "aws_message_security_group_instance_name" {
  value = module.sg-message.security_group_name
}
output "aws_front_alb_id" {
  value = module.alb-front.lb_id
}

output "aws_front_alb_arn" {
  value = module.alb-front.lb_arn
}

output "aws_front_alb_dns_name" {
  value = module.alb-front.lb_dns_name
}

output "aws_front_alb_arn_suffix" {
  value = module.alb-front.lb_arn_suffix
}

output "aws_front_alb_zone_id" {
  value = module.alb-front.lb_zone_id
}

output "aws_front_alb_target_group_arns" {
  value = module.alb-front.target_group_arns
}

output "aws_front_alb_target_group_arns_suffixes" {
  value = module.alb-front.target_group_arn_suffixes
}

output "aws_front_alb_target_group_names" {
  value = module.alb-front.target_group_names
}

output "route53_zone_zone_id" {
  description = "Zone ID of Route53 zone"
  value       = module.private-route53.route53_zone_zone_id
}

output "route53_zone_name_servers" {
  description = "Name servers of Route53 zone"
  value       = module.private-route53.route53_zone_name_servers
}

output "route53_zone_name" {
  description = "Name of Route53 zone"
  value       = module.private-route53.route53_zone_name
}


/*

output "aws_db_alb_id" {
  value = module.alb-db.lb_id
}

output "aws_db_alb_arn" {
  value = module.alb-db.lb_arn
}

output "aws_db_alb_dns_name" {
  value = module.alb-db.lb_dns_name
}

output "aws_db_alb_arn_suffix" {
  value = module.alb-db.lb_arn_suffix
}

output "aws_db_alb_zone_id" {
  value = module.alb-db.lb_zone_id
}

output "aws_db_alb_target_group_arns" {
  value = module.alb-db.target_group_arns
}

output "aws_db_alb_target_group_arns_suffixes" {
  value = module.alb-db.target_group_arn_suffixes
}

output "aws_db_alb_target_group_names" {
  value = module.alb-db.target_group_names
}


output "aws_cache_alb_id" {
  value = module.alb-cache.lb_id
}

output "aws_cache_alb_arn" {
  value = module.alb-cache.lb_arn
}

output "aws_cache_alb_dns_name" {
  value = module.alb-cache.lb_dns_name
}

output "aws_cache_alb_arn_suffix" {
  value = module.alb-cache.lb_arn_suffix
}

output "aws_cache_alb_zone_id" {
  value = module.alb-cache.lb_zone_id
}

output "aws_cache_alb_target_group_arns" {
  value = module.alb-cache.target_group_arns
}

output "aws_cache_alb_target_group_arns_suffixes" {
  value = module.alb-cache.target_group_arn_suffixes
}

output "aws_cache_alb_target_group_names" {
  value = module.alb-cache.target_group_names
}



output "aws_message_alb_id" {
  value = module.alb-message.lb_id
}

output "aws_message_alb_arn" {
  value = module.alb-message.lb_arn
}

output "aws_message_alb_dns_name" {
  value = module.alb-message.lb_dns_name
}

output "aws_message_alb_arn_suffix" {
  value = module.alb-message.lb_arn_suffix
}

output "aws_message_alb_zone_id" {
  value = module.alb-message.lb_zone_id
}

output "aws_message_alb_target_group_arns" {
  value = module.alb-message.target_group_arns
}

output "aws_message_alb_target_group_arns_suffixes" {
  value = module.alb-message.target_group_arn_suffixes
}

output "aws_message_alb_target_group_names" {
  value = module.alb-message.target_group_names
}

*/

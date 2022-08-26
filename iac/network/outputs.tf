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


output "aws_elb_security_group_id" {
  value = module.sg-elb.security_group_id
}

output "aws_elb_security_group_instance_name" {
  value = module.sg-elb.security_group_name
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

/*

output "aws_security_group_elb_id" {
  value = module.sg.aws_security_group_elb_id
}

output "aws_elb_name" {
  value = module.elb.aws_elb_name
}

output "aws_elb_dns_name" {
  value = module.elb.aws_elb_dns_name
}

output "aws_elb_zone_id" {
  value = module.elb.aws_elb_zone_id
}

output "aws_route53_zone_id" {
  value = module.route53.aws_route53_zone_id
}

output "aws_route53_zone_nsservers" {
  value = module.route53.aws_route53_zone_nsservers
}*/


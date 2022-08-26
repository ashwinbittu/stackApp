variable "tf_org" {
}

variable "tf_host" {
}

variable "app_env" {
}

variable "app_name" {
}

variable "app_id" {
}

variable "no_of_subnets" {
}

variable "aws_vpc_cidr_block" {
}

variable "aws_vpc_instance_tenancy" {
}

variable "repave_strategy" {
  default = "rolling"
}

variable "aws_vpc_id" {
  default = ""
}


variable "aws_subnet_ids" {
  default = ""
}

variable "key_name" {
  default = ""
}

/*

variable "aws_region" {
  default = ""
}


variable "aws_security_group_elb_id" {
  default = ""
}

variable "path_to_public_key" {
}

variable "aws_route53_zone_name" {
}

variable "aws_elb_name" {
  default = ""
}

variable "aws_elb_dns_name" {
  default = ""
}

variable "aws_elb_zone_id" {
  default = ""
}

variable "aws_route53_record_name" {
}

variable "aws_sg_name" {
}

variable "aws_route53_zone_id" {
}*/

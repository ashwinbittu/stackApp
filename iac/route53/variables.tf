
variable "aws_region" {
  default = ""
}

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

variable "aws_route53_private_zone_name" {
  default = ""
}

variable "aws_route53_private_db_record" {
  default = ""
}

variable "aws_route53_private_msg_record" {
  default = ""
}

variable "aws_route53_private_cache_record" {
  default = ""
}

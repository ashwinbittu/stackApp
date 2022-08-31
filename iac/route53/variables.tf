
variable "aws_region" {
  default = ""
}

variable "tf_org" {
}

variable "tf_host" {
}

variable "app_env" {
  default = ""
}

variable "app_name" {
    default = ""
}

variable "app_id" {
    default = ""
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


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

variable "app_version" {
}

variable "repave_strategy" {
}

variable "inst_type" {
}

variable "aws_subnet_ids" {
  default = ""
}

variable "aws_security_group_instances_id" {
  default = ""
}

variable "aws_ebs_snap_id" {
  default = ""
}

variable "aws_ebs_volume_size" {
  default = ""
}

variable "aws_ebs_volume_type" {
  default = ""
}

variable "inst_device_name" {
}

variable "ami_owners" {
}

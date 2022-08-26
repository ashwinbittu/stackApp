output "aws_launch_configuration_name" {
  value = module.launch-configuration.aws_launch_configuration_name
}

output "aws_autoscaling_group_name" {
  value = module.asg.aws_autoscaling_group_name
}
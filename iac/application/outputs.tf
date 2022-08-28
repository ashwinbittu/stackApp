output "app-launch-temmplate_id" {
  value = module.app-launch-template.launch_template_id
}

output "app-asg_id" {
  value = module.app-asg.autoscaling_group_id
}

output "db-launch-temmplate_id" {
  value = module.db-launch-template.launch_template_id
}

output "db-asg_id" {
  value = module.db-asg.autoscaling_group_id
}

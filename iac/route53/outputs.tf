output "db-instance-ids" {
    value = data.aws_instances.db-asg-instances.ids
}

/*

output "message-instance-ids" {
    value = data.aws_instances.message-asg-instances.ids
}

output "cache-instance-ids" {
    value = data.aws_instances.cache-asg-instances.ids
}

*/
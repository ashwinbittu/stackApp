output "db-instance-private_ips" {
    value = data.aws_instances.db-asg-instances.private_ips
}

/*

output "message-instance-private_ips" {
    value = data.aws_instances.message-asg-instances.private_ips
}

output "cache-instance-private_ips" {
    value = data.aws_instances.cache-asg-instances.private_ips
}

*/
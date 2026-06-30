output "monitoring_server_private_ip" {
  description = "Private IP of the Monitoring (Parent) Server 6"
  value       = aws_instance.monitoring_node.private_ip
}

output "monitoring_server_public_ip" {
  description = "Public IP of the Monitoring (Parent) Server 6"
  value       = aws_instance.monitoring_node.public_ip
}

output "app_servers_private_ips" {
  description = "Private IPs of the Application (Child) Servers 1-5"
  value       = aws_instance.app_nodes[*].private_ip
}

output "app_servers_public_ips" {
  description = "Public IPs of the Application (Child) Servers 1-5"
  value       = aws_instance.app_nodes[*].public_ip
}
output "trend_public_ip" {
  description = "Public IP of the Jenkins server"
  value       = aws_instance.trend.public_ip
}

output "trend_public_dns" {
  description = "Public DNS of the trend server"
  value       = aws_instance.trend.public_dns
}

output "trend_instance_id" {
  description = "EC2 Instance ID of trend"
  value       = aws_instance.trend.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public_subnet.id
}

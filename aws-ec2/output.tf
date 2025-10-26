output "aws_instance_public_ip" {
  description = "The public IP address of the AWS EC2 instance"
  value       = aws_instance.myserver.public_ip
  
}
output "instance_public_ip" {
  description = "The public IP address of the NGINX server"
  value       = aws_instance.nginx_server.public_ip 

}


output "instance_url" {
  description = "The URL to access the NGINX server"
  value       = "http://${aws_instance.nginx_server.public_ip}" 
  
}
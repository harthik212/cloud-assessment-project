output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.web.public_dns
}

output "site_url" {
  description = "HTTP URL for the deployed static site."
  value       = "http://${aws_instance.web.public_dns}"
}

output "ssh_command" {
  description = "Example SSH command. Replace the key path with your local private key path."
  value       = "ssh -i path/to/private-key.pem ec2-user@${aws_instance.web.public_ip}"
}

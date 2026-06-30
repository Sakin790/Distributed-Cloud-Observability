variable "aws_region" {
  description = "AWS region to deploy the instances"
  type        = string
  default     = "us-east-1" 
}

variable "ami_id" {
  description = "Ubuntu 22.04 or 24.04 AMI ID (HVM, SSD Volume)"
  type        = string
  default     = "ami-0c7217cdde317cfec" 
}

variable "instance_type" {
  description = "Instance type for the application nodes (Server 1-5)"
  type        = string
  default     = "t2.micro"
}

variable "my_ip" {
  description = "Your public IP address for secure SSH and UI access (CIDR format, e.g., 203.0.113.50/32)"
  type        = string
  default     = "0.0.0.0/0" # নিরাপত্তার স্বার্থে '0.0.0.0/0' এর বদলে আপনার নিজস্ব পাবলিক আইপি (IP/32) ব্যবহার করা শ্রেয়
}

variable "key_name" {
  description = "Name of the AWS EC2 Key Pair to allow SSH access"
  type        = string
  default     = "YOUR_KEY_PAIR_NAME" # আপনার AWS Key Pair (.pem ফাইলের নাম) এখানে দিন
}
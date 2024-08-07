
variable "domain" {
  type        = string
  default     = "yp3yp3.online"
}

variable "environment_name" {
  description = "production or staging"
  type        = string
  default     = "staging"
  validation {
    condition     = contains(["staging", "production"], var.environment_name)
    error_message = "Only production or staging."
  }
}
variable "ami" {
  description = "Amazon machine image to use for ec2 instance"
  type        = string
  default     = "ami-04a81a99f5ec58529" # Ubuntu 24.04 LTS // us-east-1
}
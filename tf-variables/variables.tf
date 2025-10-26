variable "region" {
  description = "value of region"
  type        = string
  default     = "ap-south-1"
}


variable "instance_type" {
  description = "Type of instance"
  type        = string
  validation {
    condition     = var.instance_type == "t2.micro" || var.instance_type == "t3.micro" || var.instance_type == "t3a.micro"
    error_message = "Instance type must be one of t2.micro, t3.micro, or t3a.micro"
  }

}


# variable "root_delete_on_termination" {
#   description = "Whether to delete root volume on termination"
#   type        = bool
#   default     = true

# }

# variable "root_volume_size" {
#   description = "Size of root volume in GB"
#   type        = number
#   default     = 30

# }

# variable "root_volume_type" {
#   description = "Type of root volume"
#   type        = string
#   default     = "gp2"

# }

variable "root_block_config" {
  description = "Root block device configuration"
  type = object({
    delete_on_termination = bool
    volume_size           = number
    volume_type           = string
  })
  default = {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

}

variable "additional_tags" {
  type        = map(string) #example of map variable
  description = "Additional tags to apply to resources"
  default     = {}
}
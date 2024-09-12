variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default = "10.0.0.0/16"
  
}

variable "ami" {
    default = "your ami here"
  
}

variable "instance_type" {
    default = "t2.micro"
  
}
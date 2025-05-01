variable "ec2_instance_type" {
  default = "t2.micro"
  type = string
}

variable "ec2_prod_root_storage_size" {
    default = 10
    type = number
}

variable "ec2_test_root_storage_size" {
    default = 8
    type = number  
}

variable "ec2_ami_id" {
    default = "ami-0df368112825f8d8f"
    type = string
}

variable "env" {
    default = "dev"    
    type = string  
}
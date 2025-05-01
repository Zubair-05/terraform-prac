# key - pair
# VPC
# security - group

resource "aws_key_pair" "terraform_key_pair" {
  key_name = "terraform-key-ec2"
  public_key = file("terraform-key-ec2.pub")
}

resource "aws_default_vpc" "default" {
  
}

resource "aws_security_group" "terraform_security_group" {
  name = "${var.env}-automate-sg"
  description = "This will create an TF generated security group"
  vpc_id = aws_default_vpc.default.id  #interpolation : is a way in which we inherit or extract values from tf block

  tags = {
    Name = "${var.env}-automate-sg"
    Environment = var.env
  }

  #inbound rules => ingress
  ingress { 
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "To open port 22"
  } 

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "To open port 80"
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "To open port 443"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "To open all the ports from instance to internet"
  }
}


resource "aws_instance" "terraform-ec2-instance" {
    # count = 2 
    for_each = tomap({
        automated_instance_1 = var.env == "prod" ? "t2.medium" : "t2.micro"
        # automated_instance_2 = "t3.micro"
    })

    depends_on = [ aws_key_pair.terraform_key_pair ]
    key_name = aws_key_pair.terraform_key_pair.key_name
    security_groups = [aws_security_group.terraform_security_group.name]
    instance_type = each.value
    ami = var.ec2_ami_id
    user_data = file("install_nginx.sh")
    root_block_device {
      volume_size = var.env == "prod" ? var.ec2_prod_root_storage_size : var.ec2_test_root_storage_size
      volume_type = "gp3"
    }

   tags = {
      Environment =  var.env
      Name = "${var.env}-${each.key}"
   }
  
}
provider "aws" {
  region = "ap-northeast-2"
}

variable "vpc_id"{
  default = "vpc-03e45db2ed2e3291c"

}

//az1 subnet variable
variable "pa_az1_mgt_subnet_id"{
  default = "subnet-0c7a46468eb697362"
}

variable "pa_az1_GWLB_subnet_id"{
  default = "subnet-0b79d3bb1ce1f5022"
}

variable "pa_az1_public_subnet_id"{
  default = "subnet-0de0e5c7b0fd2cf38"
}

//az2 subnet variable
variable "pa_az2_mgt_subnet_id"{
  default = "subnet-03be93e5ef3a6bf0b"
}

variable "pa_az2_public_subnet_id"{
  default = "subnet-0531ea46f2b6b5aac"
}

variable "pa_az2_GWLB_subnet_id"{
  default = "subnet-0b3af5233fa0257ed"
}

//security group
resource "aws_security_group" "allow-mgt-sg-iac" {
  name        = "allow-pa-mgt-sg-iac"
  description = "Allow pa-sg-mgt-traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "allow-443"
    from_port        = 0
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "allow-22"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-pa-mgt-sg"
  }
}

resource "aws_security_group" "allow-pa-traffic-sg-iac" {
  name        = "allow-pa-traffic-sg-iac"
  description = "Allow pa-sg all traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "allow-pa-traffic-sg"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-pa-traffic-sg"
  }
}


resource "aws_eip" "pa1-Untrust" {
  network_interface = aws_network_interface.pa-az1-Untrust.id

  tags = {
    Name = "PA1-EIP"
  }
}

resource "aws_eip" "pa2-Untrust" {
  network_interface = aws_network_interface.pa-az2-Untrust.id

  tags = {
    Name = "PA2-EIP"
  }
}


//network interface
resource "aws_network_interface" "pa-az1-mgt" {
  subnet_id       = var.pa_az1_mgt_subnet_id
  security_groups = [aws_security_group.allow-mgt-sg-iac.id]
  source_dest_check = false
  description = "PA-AZ1-MGT"

  tags = {
    Name = "PA-AZ1-MGT"
  }
}

resource "aws_network_interface" "pa-az1-GWLB" {
  subnet_id       = var.pa_az1_GWLB_subnet_id_id
  security_groups = [aws_security_group.allow-pa-traffic-sg-iac.id]
  source_dest_check = false
  description = "PA-AZ1-GWLB"

  tags = {
    Name = "PA-AZ1-GWLB"
  }
}

resource "aws_network_interface" "pa-az1-Untrust" {
  subnet_id       = var.pa_az1_public_subnet_id
  security_groups = [aws_security_group.allow-pa-traffic-sg-iac.id]
  source_dest_check = false
  description = "PA-AZ1-Untrust"

  tags = {
    Name = "PA-AZ1-Untrust"
  }
}

resource "aws_network_interface" "pa-az2-mgt" {
  subnet_id       = var.pa_az2_mgt_subnet_id
  security_groups = [aws_security_group.allow-mgt-sg-iac.id]
  source_dest_check = false
  description = "PA-AZ2-MGT"

  tags = {
    Name = "PA-AZ2-MGT"
  }
}

resource "aws_network_interface" "pa-az2-GWLB" {
  subnet_id       = var.pa_az2_GWLB_subnet_id_id
  security_groups = [aws_security_group.allow-pa-traffic-sg-iac.id]
  source_dest_check = false
  description = "PA-AZ2-GWLB"

  tags = {
    Name = "PA-AZ2-GWLB"
  }
}

resource "aws_network_interface" "pa-az2-Untrust" {
  subnet_id       = var.pa_az2_public_subnet_id
  security_groups = [aws_security_group.allow-pa-traffic-sg-iac.id]
  source_dest_check = false
  description = "PA-AZ2-Untrust"

  tags = {
    Name = "PA-AZ2-Untrust"
  }
}

//instance
resource "aws_instance" "az1_paloalto" {
  ami = "ami-03c43a54eb66418b3"
  instance_type = "m5.2xlarge"
  key_name = "juwon-aws-key-2023"
  availability_zone = "ap-northeast-2a"
  user_data = "mgmt-interface-swap=enable"

  network_interface {
    network_interface_id = aws_network_interface.pa-az1-mgt.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.pa-az1-GWLB.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.pa-az1-Untrust.id
    device_index         = 2
  }

  root_block_device {
    volume_size = 60

  }

  tags = {
    Name = "Paloalto_AZ1"
  }
}

resource "aws_instance" "az2_paloalto" {
  ami = "ami-03c43a54eb66418b3"
  instance_type = "m5.2xlarge"
  key_name = "juwon-aws-key-2023"
  availability_zone = "ap-northeast-2c"
  user_data = "mgmt-interface-swap=enable"

    network_interface {
    network_interface_id = aws_network_interface.pa-az2-mgt.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.pa-az2-GWLB.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.pa-az2-Untrust.id
    device_index         = 2
  }

  root_block_device {
    volume_size = 60

  }

  tags = {
    Name = "Paloalto_AZ2"
  }

}
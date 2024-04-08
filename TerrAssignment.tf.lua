provider "aws"{
    region ="us-east-1"
}

variable "instance1_name"{
    description ="Name of the first EC2 Instance"
    type        =  string
}

variable "instance2_name"{
    description ="Name of second EC2 Instance"
    type        = string
}

resource "aws_vpc" "main"{
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet_az1"{
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone ="us-east-1a"
}

resource "aws_subnet" "private_subnet_az1"{
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone ="us-east-1a"
}

resource "aws_subnet" "public_subnet_az2"{
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.3.0/24"
    availability_zone ="us-east-1b"
}

resource "aws_subnet" "public_subnets_az2"{
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.4.0/24"
    availability_zone ="us-east-1b"
}

resource "aws_instance" "instance1"{
    ami ="ami-296190057073"
    instance_type = "t2.small"
    subnet_id = aws_subnet.public_subnet_az1.id
    associate_public_ip_address =true
    tags = {
        Name = var.instance1_name
    }
}

resource "aws_instance" "instance2"{
    ami ="ami-296190057073"
    instance_type = "t2.small"
    subnet_id = aws_subnet.public_subnet_az2.id
    associate_public_ip_address =true
    tags = {
        Name = var.instance2_name
    }
}

resource "aws_db_instance" "example"{
   allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.small"
 // name                 = "mydb"
  username             = "admin"
  password             = "admin123"
  db_subnet_group_name = "my-dbsubnet-group"
  
   // subnet_group_name            ="my-subnet-group"
    vpc_security_group_ids =     [aws_security_group.web_servers.id]
    
}

resource "aws_security_group" "web_servers"{
    vpc_id = aws_vpc.main.id
    
    egress{
        from_port   =0
        to_port     =0
        protocol     ="-1"
        cidr_blocks =["0.0.0.0/0"]
    
    }
    
    egress{
        from_port   =80
        to_port     =80
        protocol     ="tcp"
        cidr_blocks =["0.0.0.0/0"]
    
    }
}

resource "aws_security_group_rule" "rds_ingress" {
    type                    = "ingress"
    from_port               = 3306
    to_port                 = 3306 
    protocol                = "tcp"
    security_group_id       = aws_db_instance.example.vpc_security_group_id[0]
    source_security_group_id = aws_security_group.web_servers.id
}


output "instance1_public_ip" {
    value = aws_instance.instance1.public_ip
}

output "instance2_public_ip" {
    value = aws_instance.instance2.public_ip
}

output "rds_endpoint" {
    value = aws_db_instance.example.endpoint
}

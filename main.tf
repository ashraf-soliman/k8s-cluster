provider "aws" {
    region = var.aws_region
}

locals {
  project_name = "K8s_cluster"
}

resource "aws_vpc" "k8s-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "${local.project_name}-vpc"
    }
}

resource "aws_subnet" "k8s-subnet" {
  vpc_id            = aws_vpc.k8s-vpc.id
  cidr_block        = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.project_name}-subnet"
  }
}

resource "aws_internet_gateway" "k8s-igw" {
  vpc_id = aws_vpc.k8s-vpc.id
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.k8s-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.k8s-igw.id
}

resource "aws_route_table" "k8s-rtb" {
  vpc_id = aws_vpc.k8s-vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"  
    gateway_id = aws_internet_gateway.k8s-igw.id 
  }
}

resource "aws_main_route_table_association" "main_association" {
  vpc_id             = aws_vpc.k8s-vpc.id
  route_table_id     = aws_route_table.k8s-rtb.id
}

resource "aws_security_group" "k8s-cluster-sg" {
  name        = "k8s-cluster-sg"
  description = "k8s-cluster-sg"
  vpc_id      = aws_vpc.k8s-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "master" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = "k8s-cluster-key"
  subnet_id     = aws_subnet.k8s-subnet.id
  vpc_security_group_ids = [aws_security_group.k8s-cluster-sg.id]
  user_data = file("./create-ansible-user.sh")
  tags = {
    Name = "${local.project_name}-master"
  }
}

# resource "aws_instance" "node1" {
#   ami           = var.ami_id
#   instance_type = var.instance_type
#   key_name      = "k8s-cluster-key"
#   subnet_id     = aws_subnet.k8s-subnet.id
#   vpc_security_group_ids = [aws_security_group.k8s-cluster-sg.id]
#   user_data = file("./create-ansible-user.sh")
#   tags = {
#     Name = "${local.project_name}-node1"
#   }
# }

# resource "aws_instance" "node2" {
#   ami           = var.ami_id
#   instance_type = var.instance_type
#   key_name      = "k8s-cluster-key"
#   subnet_id     = aws_subnet.k8s-subnet.id
#   vpc_security_group_ids = [aws_security_group.k8s-cluster-sg.id]
#   user_data = file("./create-ansible-user.sh")
#   tags = {
#     Name = "${local.project_name}-node1"
#   }
# }

output "master_public_ip" {
  value = aws_instance.master.public_ip
}
# output "node1_public_ip" {
#   value = aws_instance.node1.public_ip
# }
# output "node2_public_ip" {
#   value = aws_instance.node2.public_ip
# }
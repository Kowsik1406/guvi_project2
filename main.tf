provider "aws" {
  region = var.region
}

#####################################
# VPC
#####################################

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

###################################
# Internet Gateway
###################################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

###################################
# Public Subnet
###################################

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

##################################
# Route Table
##################################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

#################################
# Associate Subnet with Route Table
#################################

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

################################
# Security Group
################################

resource "aws_security_group" "allow_ports_sg" {
  name        = "allow_ports_sg"
  description = "Allow HTTP/HTTPS/SSH"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Jenkins web UI
  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Open to the internet
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ports_sg"
  }
}

############################
# EC2 Instance (Jenkins)
############################

resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_ports_sg.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
  #!/bin/bash

  # Update package metadata and install packages
  sudo yum clean all
  sudo yum update -y

  # Install Docker
  sudo yum install -y docker
  sudo systemctl enable docker
  sudo systemctl start docker

  # Add ec2-user and jenkins to Docker group
  sudo usermod -aG docker ec2-user
  sudo usermod -aG docker jenkins

  
  # Install Amazon Corretto 21 Java
  sudo yum install -y java-21-amazon-corretto

  # Add Jenkins repo
  sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

  # Refresh and install Jenkins
    sudo yum update -y
    sudo yum install -y jenkins
  
  # Enable and start Jenkins
  sudo systemctl enable jenkins
  sudo systemctl start jenkins

  # Restart Jenkins after adding to Docker group
  sudo systemctl restart jenkins
  EOF

  tags = {
    Name = "jenkins-server"
  }
}

############################
# IAM Role for EC2
############################

resource "aws_iam_role" "ec2_role" {
  name = "ec2-role-project2-guvi"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Recommended minimum policy for EC2
resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
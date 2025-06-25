resource "aws_vpc" "sukesh_vpc" {
  cidr_block = "17.0.0.0/16"
  tags = {
    Name = "sukesh_vpc"
  }
}


resource "aws_internet_gateway" "sukesh_igw" {
    vpc_id = aws_vpc.sukesh_vpc.id
    depends_on = [ aws_vpc.sukesh_vpc ]
    tags = {
      Name = "sukesh_igw"
    }
}


#public_sn

resource "aws_subnet" "sukesh_pub_sn" {
  vpc_id = aws_vpc.sukesh_vpc.id
  cidr_block = "17.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}


resource "aws_route_table" "sukesh_route_table" {
  vpc_id = aws_vpc.sukesh_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sukesh_igw.id
  }
  tags = {
    Name = "sukesh_rt"
  }
}

resource "aws_route_table_association" "sukesh_rt_asc" {
  subnet_id = aws_subnet.sukesh_pub_sn.id
  route_table_id = aws_route_table.sukesh_route_table.id
}


#sg
resource "aws_security_group" "sukesh_sg" {
  name = "allow_access"
  vpc_id = aws_vpc.sukesh_vpc.id
  ingress{
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  egress{
    description = "egress_all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  tags = {
    Name = "sukesh_sg"
  }
}


# EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sukesh_pub_sn.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.sukesh_sg.id]

  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y ruby wget

              cd /home/ubuntu
              wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto

              systemctl start codedeploy-agent
              systemctl enable codedeploy-agent
              EOF

  tags = {
    Name = "public-ec2"
  }
}



variable "key_name" {
    description = "name of key to be created"
    type = string
}






# #codedeploy


# resource "aws_codedeploy_app" "sukesh_web_app" {
#   name = "MyApp"
#   compute_platform = "Server"
# }

# resource "aws_codedeploy_deployment_group" "web_app_group" {
#   app_name              = aws_codedeploy_app.web_app.name
#   deployment_group_name = "MyDeploymentGroup"
#   service_role_arn      = aws_iam_role.codedeploy_service.arn

#   ec2_tag_set {
#     ec2_tag_filter {
#       key   = "Role"
#       type  = "KEY_AND_VALUE"
#       value = "CodeDeployTarget"
#     }
#   }

#   deployment_config_name = "CodeDeployDefault.AllAtOnce"
# }

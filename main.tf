provider "aws" {
  region = "us-east-1"
  
}


resource "aws_key_pair" "example" {
    key_name   = "example-key"
    public_key = file("/Users/mac/.ssh/id_rsa.pub")
  
}

resource "aws_vpc" "myvpc" {
    cidr_block = var.cidr_block
  
}

resource "aws_subnet" "sub1" {
    vpc_id     = aws_vpc.myvpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
  
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myvpc.id
  
}

resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
  
}

resource "aws_route_table_association" "rta1" {
    subnet_id      = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id
  
}

resource "aws_security_group" "wedsg" {
    name = "web"
    vpc_id = aws_vpc.myvpc.id

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    
  
}

resource "aws_instance" "server" {
    ami           = var.ami
    instance_type = var.instance_type
    key_name      = aws_key_pair.example.key_name
    subnet_id     = aws_subnet.sub1.id
    vpc_security_group_ids = [aws_security_group.wedsg.id]

    connection {
        type        = "ssh"
        user = "ubuntu"
        private_key = file("/Users/mac/.ssh/id_rsa")
        host = self.public_ip
    }

    provisioner "file" {
        source      = "/Users/mac/terraform_project/app.py"
        destination = "/home/ubuntu/app.py"
      
    }

    provisioner "remote-exec" {
        inline = [
            "echo 'Hello, From the remote instance' ",
            "sudo apt update -y",
            "sudo apt install python3 -y",
            "sudo apt install python3-pip -y",
            "cd /home/ubuntu",
            "sudo apt install python3-flask",
            "sudo python3 app.py &"
        ]
      
    }
  
}




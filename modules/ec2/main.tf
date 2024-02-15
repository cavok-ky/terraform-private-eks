# EC2 instance
resource "aws_instance" "instance" {
  ami                         = var.AMI
  instance_type               = var.INSTANCE_TYPE
  key_name                    = var.KEY_PAIR_NAME
  associate_public_ip_address = var.ASSOCIATE_PUBLIC_IP
  subnet_id                   = var.SUBNET_ID
  user_data        = file("${path.module}/ec2-init.sh") 
  vpc_security_group_ids      = [
    aws_security_group.instance-sg.id
  ]
  tags = {
    Name = "${var.EC2_NAME}"
  }  
}

# Security group for EC2 instance
resource "aws_security_group" "instance-sg" {
  name = "${var.EC2_NAME}-sg"
  description = "attached to ${var.EC2_NAME} to allow SSH"
  vpc_id      = var.VPC_ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.LOCAL_HOST_CIDR]
    security_groups = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group rule for jenkins-server instance
resource "aws_security_group_rule" "allow-8080" {
  count = var.EC2_NAME == "jenkins-server" ? 1 : 0

  type                     = "ingress"
  to_port                  = 8080
  protocol                 = "tcp"
  from_port                = 8080
  cidr_blocks = [var.LOCAL_HOST_CIDR]
  security_group_id        = aws_security_group.instance-sg.id
}
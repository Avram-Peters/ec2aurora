
  resource "aws_security_group" "database_sg" {
    vpc_id = aws_vpc.mooglevpc.id
    name = "${var.application_name}-backend-sg"
    ingress {
      from_port = 5432
      protocol = "TCP"
      to_port = 5432
      description = "Ingress to aurora database"
      cidr_blocks = [
        "24.207.212.89/32"]

      //  This is where we'll need to use the sg's from EKS
      //    security_groups = []
    }
    ingress {
      from_port = 5432
      protocol = "TCP"
      to_port = 5432
      security_groups = [aws_security_group.ec2_sg.arn]
    }

    tags = merge(var.tags, {"Name":"${var.application_name}-backend-sg"})
  }


resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.mooglevpc.id
  name = "${var.application_name}-frontend-sg"
  ingress {
    from_port = 22
    protocol = "TCP"
    to_port = 22
    cidr_blocks = [
        "24.207.212.89/32",
        "192.94.40.70/32",
        "192.94.40.40/32"
      ]
  }

  description = "ssh access to ec2"

  tags = merge(var.tags, {"Name":"${var.application_name}-frontend-sg"})
}

resource "aws_security_group_rule" "postgresql_egress" {
  type = "egress"
  from_port = 5432
  protocol = "TCP"
  to_port = 5432
  security_group_id = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.database_sg.arn
}

resource "aws_security_group_rule" "http_egress" {
  type = "egress"
  from_port = 80
  protocol = "TCP"
  to_port = 80
  security_group_id = aws_security_group.ec2_sg.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_egress" {
  type = "egress"
  from_port = 443
  protocol = "TCP"
  to_port = 443
  security_group_id = aws_security_group.ec2_sg.id
  cidr_blocks = ["0.0.0.0/0"]
}
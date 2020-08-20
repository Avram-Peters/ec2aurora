resource "aws_iam_role" "ec2_role" {
  name = "${var.application_name}-iamrole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  tags = var.tags
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.application_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

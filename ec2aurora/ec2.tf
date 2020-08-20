resource "tls_private_key" "emc_ec2_ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "emc_ec2_ssh_key_pair" {
  key_name = "${var.application_name}-key"
  public_key = tls_private_key.emc_ec2_ssh_key.public_key_openssh

}

data "aws_ami" "instance_ami" {
  most_recent      = true
  owners           = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

data "template_file" "cloud-init" {
  template = file("./${var.env}/scripts/startup.tpl")
  vars = {
    DATABASE_HOST = aws_rds_cluster.eca-aurora-cluster.endpoint,
    DATABASE_PORT = aws_rds_cluster.eca-aurora-cluster.port,
    DATABASE = "",
    DATABASE_USERNAME = local.db-username
    DATABASE_PASSWORD = random_password.aurora-password.result
  }
}

//data "template_cloudinit_config" "cloud-init-config" {
//
//}

resource "aws_instance" "front-end-instance" {
//  count = "${local.pet_enabled ? 1 : 0}"
  ami = data.aws_ami.instance_ami.id
  subnet_id = aws_subnet.ecasubnet-front.id
  instance_type = var.ec2-instance
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
//    "sg-d0b626a1", # ingress - internal - ssh
//    "sg-25bb2b54", # egress - external - HTTP (yum)
//    "sg-13b92962"  # egress - external - HTTPS
  ]
//  See permission.tf
  iam_instance_profile = "${var.application_name}-instance-profile"
  key_name = aws_key_pair.emc_ec2_ssh_key_pair.key_name
  root_block_device {
    volume_size = 10
  }
//  Use the script with this file name for initial updates/installs
  user_data = data.template_file.cloud-init.rendered
//  file("./scripts/startup.sh")
// Update tags
  tags = merge( var.tags, {"Name":"${var.application_name}-instance"} )
}

//extra disk space if required
resource "aws_ebs_volume" "ebs_volume_for_ec2" {
//  count = "${local.pet_enabled ? 1 : 0}"
  availability_zone = aws_subnet.ecasubnet-front.availability_zone
  size = 30
  type = "gp2"
  encrypted = true
  tags = var.tags
}
resource "aws_volume_attachment" "ec2_ebs_attachment" {
//  count = "${local.pet_enabled ? 1 : 0}"
  device_name = "/dev/sdh"
  instance_id = aws_instance.front-end-instance.id
  volume_id = aws_ebs_volume.ebs_volume_for_ec2.id
  force_detach = true

}


# Export the pem file to a secret, stored in secret-manager
resource "aws_secretsmanager_secret" "ec2-secret" {
  name = "${var.env}-${var.application_name}-ec2-certificate"
  description = "Private Key for EC2 Instance"
  recovery_window_in_days = local.secrets_ttl
  tags = merge(
      var.tags,
      {"Name": "${var.application_name}-pem"}
    )
}

resource "aws_secretsmanager_secret_version" "ec2-secret-value" {
  secret_id = aws_secretsmanager_secret.ec2-secret.id
  secret_string = jsonencode({
    key1 = aws_key_pair.emc_ec2_ssh_key_pair.key_name
    key2 = tls_private_key.emc_ec2_ssh_key.private_key_pem
  })
  version_stages = ["AWSCURRENT"]

}


resource "local_file" "pem_key" {
  filename = "${aws_key_pair.emc_ec2_ssh_key_pair.key_name}.pem"
  content = tls_private_key.emc_ec2_ssh_key.private_key_pem
}
provider "aws" {
  profile = "default"
  region = "us-east-2"
}

provider "random" {}

provider "template" {}

terraform {
  backend "s3"{

  }
}

resource "random_password" "aurora-password" {
  length = 40
  special = true
  override_special = "!#$^><_-+="
}

resource "aws_secretsmanager_secret" "aurora-secret" {
  name = "${var.env}-${var.application_name}-db-secret"
  description = "Secret for aurora db"
  recovery_window_in_days = local.secrets_ttl
  tags = merge(
      var.tags,
      {"Name": "${var.application_name}-secret"}
    )
}

resource "aws_secretsmanager_secret_version" "aurora-secret-value" {
  secret_id = aws_secretsmanager_secret.aurora-secret.id
  secret_string = jsonencode({
    key1 = local.db-username
    key2 = random_password.aurora-password.result
  })

  version_stages = ["AWSCURRENT"]

}


resource "aws_resourcegroups_group" "app_resource_group" {
  name = var.application_name
  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": ["AWS::AllSupported"],
  "TagFilters": [
    {
       "Key": "Purpose",
       "Values": ["${var.tags["Purpose"]}"]
    }
  ]
}
JSON
  }
}
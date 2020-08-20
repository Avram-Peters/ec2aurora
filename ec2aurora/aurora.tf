
resource "aws_db_subnet_group" "db_subnet_group" {
  tags = var.tags
  name = "${var.application_name}-subnet-group"
  subnet_ids = [for s in aws_subnet.ecasubnet-back : s.id]
}

resource "aws_rds_cluster_instance" "eca-aurora-instances" {
  count = var.cluster-instance-count
  identifier = "${var.application_name}-cluster-${count.index}"
  cluster_identifier = aws_rds_cluster.eca-aurora-cluster.cluster_identifier
  instance_class = var.aurora-instance-class
  engine = var.db-engine
  engine_version = var.db-engine-version
  publicly_accessible = var.debug
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  tags = merge(
      var.tags,
      {"Name": "${var.application_name}-instances"}
    )
  depends_on = [aws_security_group.database_sg, aws_rds_cluster.eca-aurora-cluster]
}


resource "aws_rds_cluster" "eca-aurora-cluster" {
  cluster_identifier = "${var.env}-${var.application_name}-cluster"
  database_name = local.db-username
  master_username = local.db-username
  master_password = random_password.aurora-password.result
  engine = var.db-engine
  engine_version = var.db-engine-version
  skip_final_snapshot = var.debug
  storage_encrypted = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  #kms
  port = 5432
  iam_database_authentication_enabled = true

  tags = merge(
      var.tags,
      {"Name": "${var.application_name}-cluster"}
    )
}

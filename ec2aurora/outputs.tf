output "cidr_blocks" {
  value = local.cidr_subnets
}
output "ec2_role_arn" {
  value = "${aws_iam_role.ec2_role.arn}"
}
output "ec2_instance_profile_arn" {
  value = "${aws_iam_instance_profile.ec2_instance_profile.arn}"
}
output "ec2_instance_profile_name" {
  value = "${aws_iam_instance_profile.ec2_instance_profile.name}"
}
output "ec2_role_uniqe_id" {
  value = "${aws_iam_role.ec2_role.unique_id}"
}
output "ec2_role_id" {
  value = "${aws_iam_role.ec2_role.id}"
}
//exports the ip address
output "ec2_internal_ip" {
  value = "${aws_instance.front-end-instance.*.private_ip}"
}
output "aurora_address" {
  value = aws_rds_cluster.eca-aurora-cluster.endpoint
}
output "get_cert" {
  value = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.ec2-secret.name}"
}
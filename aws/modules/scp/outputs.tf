output "scp_id" {
  value = aws_organizations_policy.scp.id
}

output "attached_target_id" {
  value = var.target_id == null ? null : aws_organizations_policy_attachment.attach[0].id
}

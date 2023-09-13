
locals {
  base_dn = format("%s-%s-%s-private", var.deployment_name, var.network_type, var.company_name)
  base_id = format("%s-%s", var.deployment_name, var.environment)
  common_labels = {
    network         = lower(var.network_type)
    deployment_name = lower(var.deployment_name)
    environment     = lower(var.environment)
    base_id         = lower(local.base_id)
  }
}

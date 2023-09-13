
# output "gcp_lb_int_rpc_domain" {
#   value = module.elb.gcp_lb_int_rpc_domain
# }

# output "gcp_lb_ext_domain" {
#   value = module.elb.gcp_lb_ext_rpc_domain
# }

# output "gcp_lb_ext_geth_domain" {
#   value = module.elb.gcp_lb_ext_rpc_geth_domain
# }

output "base_dn" {
  value = local.base_dn
}
output "base_id" {
  value = local.base_id
}

output "geth_private_ips" {
  value = google_compute_instance.geth[*].network_interface.0.network_ip
}

output "validator_private_ips" {
  value = google_compute_instance.validator[*].network_interface.0.network_ip
}
output "geth_private_ips" {
  value = google_compute_instance.geth[*].network_interface.0.network_ip
}

output "validator_private_ips" {
  value = google_compute_instance.validator[*].network_interface.0.network_ip
}

output "service_account_email" {
  value = google_service_account.polygon_sa.email
}

output "polygon_sa_key" {
  value = base64decode(google_service_account_key.polygon_sa.private_key)
  sensitive = true
}

### Further development: Not being used right now ###
# output "gcp_lb_int_rpc_domain" {
#   value = module.elb.gcp_lb_int_rpc_domain
# }

# output "gcp_lb_ext_domain" {
#   value = module.elb.gcp_lb_ext_rpc_domain
# }

# output "gcp_lb_ext_geth_domain" {
#   value = module.elb.gcp_lb_ext_rpc_geth_domain
# }

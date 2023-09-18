resource "google_project_service" "compute" {
  service = "compute.googleapis.com"

  disable_on_destroy = false
}

### Launching Validators - minimum 4 ###
resource "google_compute_instance" "validator" {
  count        = var.validator_count
  name         = "${local.base_id}-validator-${count.index}"
  machine_type = var.base_instance_type
  zone         = var.zones[count.index % length(var.zones)]
  boot_disk {
    initialize_params {
      image = var.base_ami
      size  = var.boot_disk_size
      labels = merge(local.common_labels, {
        role      = "validator"
        node_name = "validator-${count.index}"
      })
    }
  }

  network_interface {
    network    = google_compute_network.network.self_link
    subnetwork = google_compute_subnetwork.private.self_link
  }
  # attached_disk {
  #   source = google_compute_disk.validator[count.index].self_link
  # }

  labels = merge(local.common_labels, {
    role      = "validator"
    node_name = "validator-${count.index}"
  })
}


# now the geth nodes
resource "google_compute_instance" "geth" {
  count        = var.geth_count
  name         = "${local.base_id}-geth-${count.index}"
  machine_type = var.base_instance_type
  zone         = var.zones[count.index % length(var.zones)]
  boot_disk {
    initialize_params {
      image = var.base_ami
      size  = var.boot_disk_size
      labels = merge(local.common_labels, {
        role      = "geth"
        node_name = "geth-${count.index}"
      })
    }
  }

  network_interface {
    network    = google_compute_network.network.self_link
    subnetwork = google_compute_subnetwork.private.self_link
  }
  # attached_disk {
  #   source = google_compute_disk.geth[count.index].self_link
  # }

  labels = merge(local.common_labels, {
    role      = "geth"
    node_name = "geth-${count.index}"
  })
}

# # now let's create a few disks for the validators and geth nodes
# resource "google_compute_disk" "geth" {
#   count = var.geth_count
#   name  = "${local.base_id}-geth-disk-${count.index}"
#   type  = "pd-standard"
#   zone  = var.zones[count.index % length(var.zones)]
#   size  = var.node_storage
#   labels = merge(local.common_labels, {
#     role      = "geth"
#     node_name = "geth-${count.index}"
#   })
# }

# resource "google_compute_disk" "validator" {
#   count = var.validator_count
#   name  = "${local.base_id}-validator-disk-${count.index}"
#   type  = "pd-standard"
#   zone  = var.zones[count.index % length(var.zones)]
#   size  = var.node_storage
#   labels = merge(local.common_labels, {
#     role      = "validator"
#     node_name = "validator-${count.index}"
#   })
# }

# This is a terraform project to deploy on GCP a polygon supernet on top of compute engine instances.

variable "project" {
  description = "The project where we want to deploy"
  type        = string
}
variable "base_instance_type" {
  description = "The type of instance that we're going to use"
  type        = string
  default     = "e2-medium"
}
variable "company_name" {
  description = "The name of the company for this particular deployment"
  type        = string
  default     = "IEU"
}

variable "create_ssh_key" {
  description = "Should a new ssh key be created or should we use the devnet_key_value"
  type        = bool
  default     = true
}

variable "deployment_name" {
  description = "The unique name for this particular deployment"
  type        = string
  default     = "gp23-poc3"
}

variable "devnet_key_value" {
  description = "The public key value to use for the ssh key. Required when create_ssh_key is false"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment for deployment for this particular deployment"
  type        = string
  default     = "devnet"
}

variable "fullnode_count" {
  description = "The number of full nodes that we're going to deploy"
  type        = number
  default     = 0
}

variable "geth_count" {
  description = "The number of geth nodes that we're going to deploy"
  type        = number
  default     = 1
  validation {
    condition = (
      var.geth_count == 0 || var.geth_count == 1
    )
    error_message = "There should only be 1 geth node, or none (if you are using another public L1 chain for bridge)."
  }
}

variable "http_rpc_port" {
  description = "The TCP port that will be used for http rpc"
  type        = number
  default     = 10002
}

variable "network_acl" {
  description = "Which CIDRs should be allowed to access the explorer and RPC"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_storage" {
  description = "The size of the storage disk attached to full nodes and validators"
  type        = number
  default     = 40
}

variable "rootchain_rpc_port" {
  description = "The TCP port that will be used for rootchain (for bridge)"
  type        = number
  default     = 8545
}

variable "route53_zone_id" {
  description = "The ID of the hosted zone to contain the CNAME record to our LB"
  type        = string
  default     = ""
}

variable "owner" {
  description = "The main point of contact for this particular deployment"
  type        = string
  default     = "user@email.com"
}

variable "private_network_mode" {
  description = "True if vms should bey default run in the private subnets"
  type        = bool
  default     = true
}

variable "region" {
  description = "The region where we want to deploy"
  type        = string
  default     = "europe-west1"
}

variable "validator_count" {
  description = "The number of validators that we're going to deploy"
  type        = number
  default     = 4
}

variable "zones" {
  description = "The availability zones for deployment"
  type        = list(string)
  default     = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
}





locals {
  network_type = "polygon-edge"
  base_ami     = "ubuntu-os-cloud/ubuntu-2204-lts"
  # base_dn      = format("%s-%s-%s-private", var.deployment_name, local.network_type, var.company_name)
  base_id      = format("%s-%s", var.deployment_name, var.environment)
  common_labels = {
    network        = lower(local.network_type)
    owner          = lower(var.owner)
    deployment_name = lower(var.deployment_name)
    environment    = lower(var.environment)
    base_id           = lower(local.base_id)
    # base_dn         = lower(local.base_dn)
  }
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
  required_version = ">= 0.13"
}

provider "google" {
  project     = var.project
  region      = var.region
}


# resource "google_compute_network" "network" {
#   name = "${local.base_id}-network"
#   # labels = local.common_labels
#   auto_create_subnetworks = false
# }

# resource "google_compute_subnetwork" "subnet" {
#   count = length(var.zones)

#   name          = "${local.base_id}-subnet-${count.index}"
#   ip_cidr_range = "10.0.${count.index}.0/24"
#   region        = var.region
#   network       = google_compute_network.network.self_link
#   private_ip_google_access = true

#   depends_on = [google_compute_network.network]

#   secondary_ip_range {
#     range_name    = "pods"
#     ip_cidr_range = "10.1.${count.index}.0/24"
#   }

#   secondary_ip_range {
#     range_name    = "services"
#     ip_cidr_range = "10.2.${count.index}.0/24"
#   }
# }


resource "google_compute_instance" "validator" {
  count = var.validator_count
  name         = "${local.base_id}-validator-${count.index}"
  machine_type = var.base_instance_type
  zone         = var.zones[count.index % length(var.zones)]
  boot_disk {
    initialize_params {
      image = local.base_ami
      labels       = merge(local.common_labels, {
        role = "validator"
        node_name = "validator-${count.index}"
      })
    }
  }

  network_interface {
    network = google_compute_network.network.self_link
    subnetwork = google_compute_subnetwork.private.self_link
  }
  attached_disk {
    source = google_compute_disk.validator[count.index].self_link
  }

  labels       = merge(local.common_labels, {
    role = "validator"
    node_name = "validator-${count.index}"
  })
}

# now let's create a few disks for the validators
resource "google_compute_disk" "validator" {
  count = var.validator_count
  name  = "${local.base_id}-validator-disk-${count.index}"
  type  = "pd-standard"
  zone  = var.zones[count.index % length(var.zones)]
  size  = var.node_storage
  labels       = merge(local.common_labels, {
    role = "validator"
    node_name = "validator-${count.index}"
  })
}

# now the geth nodes
resource "google_compute_instance" "geth" {
  count = var.geth_count
  name         = "${local.base_id}-geth-${count.index}"
  machine_type = var.base_instance_type
  zone         = var.zones[count.index % length(var.zones)]
  boot_disk {
    initialize_params {
      image = local.base_ami
      labels       = merge(local.common_labels, {
        role = "geth"
        node_name = "geth-${count.index}"
      })
    }
  }

  network_interface {
    network = google_compute_network.network.self_link
    subnetwork = google_compute_subnetwork.private.self_link
  }
  attached_disk {
    source = google_compute_disk.geth[count.index].self_link
  }

  labels       = merge(local.common_labels, {
    role = "geth"
    node_name = "geth-${count.index}"
  })
}

# now let's create a few disks for the geth nodes
resource "google_compute_disk" "geth" {
  count = var.geth_count
  name  = "${local.base_id}-geth-disk-${count.index}"
  type  = "pd-standard"
  zone  = var.zones[count.index % length(var.zones)]
  size  = var.node_storage
  labels       = merge(local.common_labels, {
    role = "geth"
    node_name = "geth-${count.index}"
  })
}










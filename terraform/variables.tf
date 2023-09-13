
variable "project" {
  description = "The project where we want to deploy"
  type        = string
  default     = "polygon-060623"
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

variable "network_acl" {
  description = "Which CIDRs should be allowed to access the explorer and RPC"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_storage" {
  description = "The size of the storage disk attached to full nodes and validators"
  type        = number
  default     = 20
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

variable "network_type" {
  description = "Network type"
  type        = string
  default     = "polygon-edge"
}

variable "base_ami" {
  description = "Image used in the instances"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "boot_disk_size" {
  description = "The size of boot disk in GBs"
  type        = number
  default     = 10
}

### Not being used right now ###
variable "rootchain_rpc_port" {
  description = "The TCP port that will be used for rootchain (for bridge)"
  type        = number
  default     = 8545
}

variable "http_rpc_port" {
  description = "The TCP port that will be used for http rpc"
  type        = number
  default     = 10002
}

# gcp-polygon-supernets
The gcp-polygon-supernets is a repository where you can deploy the polygon supernets on GCP. The version supported is the v1.0.1 for the edge and v1.12.0 for geth.

This project uses terraform to deploy 4 validator nodes and 1 rootchain called geth. Each one are deployed in a GCP VM.
Then, it is used ansible to provision them. It is inspired by [terraform-polygon-supernets](https://github.com/maticnetwork/terraform-polygon-supernets), used to deploy the polygon supernets on AWS.


## Disclaimers

- Ansible is based from the AWS repo with additional modifications to use the gcp inventory plugin and improvement to make the application run smoothly.
- Be aware that the generated terraform tfstate is local

## Requirements

- terraform
- ansible
- python
- gcloud 

## The very rough steps

1. clone the repo
2. go to the terraform directory
3. run `terraform init`
4. run `terraform apply`
5. wait for the VMs to be booted
6. add your ssh key to the project metadata 
7. ensure you can connect to the hosts using `gcloud compute ssh VM_NAME --tunnel-through-iap --zone ZONE --project PROJECT_ID`
8. run `ansible-playbook --inventory inventory.gcp.yml site.yml` to provision the hosts

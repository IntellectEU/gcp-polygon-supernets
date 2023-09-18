# gcp-polygon-supernets
The gcp-polygon-supernets is a repository where you can deploy the polygon supernets on GCP. The version supported is the v1.0.1 for the edge and v1.12.0 for geth.

This project uses terraform to deploy 4 validator nodes and 1 rootchain called geth. Each one are deployed in a GCP instance.
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

1. Clone the repo
2. Go to the terraform directory
3. Run `terraform init`
4. Run `terraform apply`
5. Wait for the instances to be booted
6. Add your ssh key to the project metadata 
7. Ensure you can connect to the hosts using `gcloud compute ssh VM_NAME --tunnel-through-iap --zone ZONE --project PROJECT_ID`
8. Go to `ansible/group_vars/all.yml` and update the following variables accordingly: `ansible_user: YOUR_USER` and `ansible_ssh_private_key_file: PATH_TO_YOUR_KEY`
9. run `ansible-playbook --inventory inventory.gcp.yml site.yml` to provision the hosts

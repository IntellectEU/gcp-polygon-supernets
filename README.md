# gcptf-polygon-supernets
Terraform deployment for polygon supernets on gcp

This project uses terraform to deploy some VMs and ansible to provision them. It is inspired by [terraform-polygon-supernets](https://github.com/maticnetwork/terraform-polygon-supernets)

This document is not intended to be the final readme file for the repo and should be rewritten before making the repository public.

## Disclaimers

- Ansible is a copy/paste from the aws repo, I've done only a few small modifications to use the gcp inventory plugin
- The workflow is not finished yet. Atm ansible crashes in the middle of the process
- I'm 100% sure right now there are harcoded variables in some places that only work for me. An example of that is the remote_user=noel in ansible.cfg file. Those vars must be replaced with values valid for everyone, and if not possible, put them on gitigored config files.
- Terraform code is ugly right now
- terraform tfstate is local atm, that is not the best for team work. But consider this will be a public repository, so not a good practice either to push potential users to an specific non-configurable remote backend

## Requirements

- terraform
- ansible
- python
- gcloud 
- some extra packages I don't remember right now might be required to establish ssh connections using gcloud iap tunnels feature

## The very rough steps

1. clone the repo
2. create the terraform.tfvars.json file with the terraform variables you wanna override. The format must be json because that format is compatible with ansible, so we can reuse the same file for both tools.
3. run `terraform init`
4. run `terraform apply`
5. run `terraform output -json > terraform.output.json` (empty for now but might be useful in the future to add extra variables needed by ansible)
  - actually once terraform is capable of creating the ssh keys and adding them to the project metadata, we can use the terraform output to get the ssh username/key
6. add your ssh key to the project metadata 
7. ensure you can connect to the hosts using `gcloud compute ssh VM_NAME --tunnel-through-iap --zone ZONE --project PROJECT_ID`
8. run `make run-ansible` to provision the hosts
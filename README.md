# gcp-polygon-supernets
The gcp-polygon-supernets is a repository where you can deploy the polygon supernets on GCP. The version supported is the v1.0.1 for the edge and v1.12.0 for geth.

This project uses terraform to deploy 4 validator nodes and 1 rootchain called geth. Each one are deployed in a GCP instance.
Then, it is used ansible to provision them. It is inspired by [terraform-polygon-supernets](https://github.com/maticnetwork/terraform-polygon-supernets), used to deploy the polygon supernets on AWS.


## Disclaimers

- Ansible is based from the AWS repo with additional modifications to use the gcp inventory plugin and improvement to make the application run smoothly.
- Be aware that the generated terraform tfstate is local

## Requirements

- Google Cloud Platform account

## Deployment Steps
The following steps are for a clean Debian based system.

#### Update and upgrade system
```bash
apt update && apt -y upgrade
```

#### Install dependencies
```bash
apt install git ansible apt-transport-https ca-certificates gnupg curl sudo wget python3-google-auth
```

#### Install terraform
[Full instructions here](https://www.hashicorp.com/official-packaging-guide?product_intent=terraform)
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

apt update && apt install terraform
```

#### Install gcloud CLI
[Full instructions here](https://cloud.google.com/sdk/docs/install#deb)
```bash
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-cli
```

#### Initiate your Google Cloud Account and authoratize access to i
```bash
gcloud init
gcloud auth application-default login

```

Note: Currently configured for GCP Region "europe-west1-b".

Output similar to:

```
Quota project "mycoolproject" was added to ADC which can be used by Google client libraries for billing and quota. Note that some services may still bill the project owning the resource.
```

#### Clone repo and enter terraform folder

```bash
git clone https://github.com/IntellectEU/gcp-polygon-supernets
cd gcp-polygon-supernets/terraform/
```



#### Init and apply terraform
```bash
terraform init
```

Expected output:

```
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```
terraform apply
```

Expected output similar to 
```
Apply complete! Resources: 18 added, 0 changed, 0 destroyed.

```
If you login to your Google Cloud Console you should see 5 new instances created.


#### Ensure you can connect to the hosts

```bash
gcloud compute ssh --zone "europe-west1-b" "gp23-poc3-devnet-validator-0" --tunnel-through-iap --project "mycoolproject"
```
Rename the project to your own project. This will also generate and upload an ssh key if you don't already have one.


#### Add your current user to the ansible yaml file.
```bash
sed -i.bak "s/YOUR_USER/$(whoami)/g" /gcp-polygon-supernets/ansible/group_vars/all.yml
```

#### Run ansible-playbook from the ansible directory
```bash
cd /gcp-polygon-supernets/ansible
ansible-playbook --inventory inventory.gcp.yml site.yml
```

This last process will take a long time so please be patient. 
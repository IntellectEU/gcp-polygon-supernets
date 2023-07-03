# TODOs

- terraform
  - enable gcp apis
  - generate service account and service account key
  - generate ssh and add it to the gcp project metadata
  - load balancers
  - firewall rules, specially ssh port
  - create fullnodes
  - populate ansible variables and keys from tf outputs if needed
  - backups for the disks?
  - ensure there are no sensitive settings on variables.tf pushed to the repo

- ansible
  - do all shit and be sure its working
  - use ansible-pull in the vms userdata to automatically provision
  - don't be lazy and avoid use of @validator and @geth as standalone ansible tags/groups [more than one supernet might be deployed on same gcp project]

- others
  - review there is no adhoc/harcoded paramenters/variables on gcp.yml ansible.cfg group_vars/ and terraform files
  - test more nodes can be added after first startup

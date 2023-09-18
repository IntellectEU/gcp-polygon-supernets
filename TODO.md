# TODOs

- terraform
  - enable gcp apis                                                 --- DONE
  - generate service account and service account key                --- DONE
  - generate ssh and add it to the gcp project metadata             --- Manual step
  - load balancers                                                  --- Not going to be DONE
  - firewall rules, specially ssh port                              --- DONE
  - create fullnodes                                                --- I don't think we need them
  - populate ansible variables and keys from tf outputs if needed   --- DONE
  - backups for the disks?                                          --- Not needed
  - ensure there are no sensitive settings on variables.tf pushed to the repo   --- DONE

- ansible
  - do all shit and be sure its working                             --- DONE
  - use ansible-pull in the vms userdata to automatically provision --- DONE
  - don't be lazy and avoid use of @validator and @geth as standalone ansible tags/groups [more than one supernet might be deployed on same gcp project] --- Not Going to be DONE. I think if we have one deployment per vpc this will not be a problem

- others
  - review there is no adhoc/harcoded paramenters/variables on gcp.yml ansible.cfg group_vars/ and terraform files   --- DONE
  - test more nodes can be added after first startup                                                                 --- DONE

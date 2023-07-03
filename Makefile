.PHONY: run-playbook
run-playbook:
	pushd ansible && \
	ansible-playbook --inventory inventory.gcp.yml --extra-vars "@local-extra-vars.yml" --extra-vars "@../terraform.tfvars.json" --extra-vars "@../terraform.output.json" site.yml && \
	popd

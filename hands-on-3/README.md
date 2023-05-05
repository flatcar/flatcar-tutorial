# Hands-on 3: deploying

Hello, the goal here is to:
* deploy Flatcar instances with IaC (Terraform)
* manipulate Terraform code
* write Flatcar provisioning with Terraform
* deploy Flatcar on OpenStack with Terraform

This is a bundle of hands-on-1 and hands-on-2 but it's not locally now and we write _everything_ as code.

# Step-by-step

```bash
# go into the terraform directory
cd terraform
# init the terraform project locally
terraform init
# get the credentials from Mathieu
# generate the plan and inspect it
terraform plan
# apply the plan
terraform apply
# go on the horizon dashboard and connect with terraform credentials
# find your instance
```

One can assert that it works by accessing the console (click on the instance then "console")

_NOTE_: it's possible to SSH into the instance but at the moment, it takes a SSH jump through the openstack (devstack) instance. If the group is small enough, you can ask Mathieu to install a public key to the demo server.
```
ssh -J user@[DEVSTACK-IP] -i ./.ssh/provisioning_private_key.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@[SERVER-IP]
```

To destroy the instance:
```
# if you are happy, destroy everything
terraform destroy
```

# Resources

* https://github.com/flatcar/flatcar-terraform/ (NOTE: the terraform code used here is based on this repository)
* https://www.flatcar.org/docs/latest/installing/cloud/openstack/

# Demo

```
asciinema play demo.cast
```

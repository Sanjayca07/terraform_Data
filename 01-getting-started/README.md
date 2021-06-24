# Terraform Getting Started

We'll be going over the basics of getting started of Terraform. You'll need to make sure to have a Linode Account if you follow along. You can go [here](https://https://linode.gvw92c.net/b1tsized) to check them out.

In the accompanying tutorial, we'll talk about installing Terrafom, initilizing directorys, and how to initialize our first terrform resource. We'll be getting most of our information from the [Linode terraform provider](https://registry.terraform.io/providers/linode/linode/latest/docs).

## Installing Terraform

For this tutorial we'll be using the manual installation, but you can use the appropriate package manager or installer of your choosing.

Download terraform from this [link](https://www.terraform.io/downloads.html). Once downloaded we'll want to unzip.

`unzip terraform*.zip -d /usr/local/bin && rm -rf terraform*.zip`

Verify that you're able to use terraform.

`terraform version`

Now that it's installed we can continue with getting started. You can also setup [terraform tab completion](https://learn.hashicorp.com/tutorials/terraform/install-cli#enable-tab-completion).

## Initializing a directory

For a directory to be initilized you'll ned to navigate into that directory through the terminal.

`cd /{terraform-path}`

Once inside of the directory a `main.tf` will need to be created. To be able to initialize you'll have to add a provider block. In the next section, you'll see an example of that block.

## Provider Block

This is a basic example of how to add a provide into a terraform file.

- [Provider Setup](./provider/main.tf)

You'll notice we need an environment variable set to be able to access Linode using a token. You can create a token [here](https://www.linode.com/docs/products/tools/linode-api/guides/get-access-token). When that block is added and file saved, then you'll be able to run a `terraform init`.

`terraform init`

This command will initialize the directory and download any necessarry modules from the provider. You'll also see a tf state file and tf lock file being added. The state will keep track of anything created with the terraform modules and the tf lock will keep checksums of the modules and assets to make sure that there are no changes or mismatches.

## Adding Linode Users

This is a basic example of how to add a resouce like a user creation into a terraform file.

- [Adding Users](./users/main.tf)

We'll be able to now add on to our terraform file and add in a user to our linode account. You'll be able to add and edit information on the user to modify the creation. Once we've added in the information we'll be able to check out configuration in order to see what changes will be made.

`terraform plan`

This will return a value that you can see if any errors will be returned or all the resources that will be created from your terraform.

If we're happy with the results of our plan, then we'll be able to apply this file.

`terraform apply`

This will also run `terraform plan` again. Once it's finished it will ask you confirm your changes. You have to enter `yes` for it to complete the creation. On completion you should be able to check in your Linode panel and confirm the new user created.

Say we don't want to keep this user. You wouldn't want to manually delete it, because the next time Terraform would run it would see the resource isn't there and recreate it. In order to remove it from your state file and confirm destruction we would first need to run `terraform destroy`. This will again run `terraform plan` and then confirm the changes. Once run you can check in Linode to verify that it's been destroyed.

## Setting up an instance

This is a basic example of how to add a resouce like an instance into a terraform file.

- [Setting up instances](./instances/main.tf)

Rather than creating a user we'd rather create a simple web instance. You'll first remove the user block and add an instance block. You can find reference to it in the [terraform provider for Linode](https://registry.terraform.io/providers/linode/linode/latest/docs/resources/instance). We'll add in the block and update settings as needed. We can validate our settings using `terraform validate` once our changes our saved. If it is, then we can do `terraform apply` and enter `yes` to confirm.

Now we have set up our instance we can connect to it and verify that it's up and running.

This has been a quick intro into some basics of terraform. You can use `terraform destroy` to spin down with the instance once you're done.

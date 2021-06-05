# Terraform State And Files

Here we'll be taking a look at `terraform state`, files, and file structure. We'll be getting most of our information from the [Linode terraform provider](https://registry.terraform.io/providers/linode/linode/latest/docs).

## Terraform State

To view state our terraform directory we can use `terraform state list`. First, we'll need to spin up some resources in order to view them. In the [state](./state) folder, you'll be able to `terraform init`, then `terraform plan` to spin up an instance and a user. Once spun up, you'll be able to run `terraform state list` in order to see all of the current resources terraform set up.

You can see the list displayed of all the resources. If you want to filter you can do `terraform state list linode_instance` or `terraform state list linode_user`. This will give you a list of any of the filtered resource types.

For more information on those specific resources you can use `terraform state show` and filter using the resource type and name. For example, you may want to view all information on a specific instance we'd use `terraform state show linode_instance.web`.

State files are the source of all truth for terraform. If it doesn't exist in the statefile, then terraform doesn't manage it. If there is an error with creation, then a resource will be marked as `tainted`. This means that on the next `terraform apply` that resource will be destroyed and recreated. You can manually mark something as tained by running `terraform taint` and tagging that specific resource. If we wanted to do so with our `linode_instance.web` we'd run `terraform taint linode_instance.web`.

Try running that command and doing another `terraform apply`. You'll see that it will has destroyed that specific instance and recreated it. You can also choose to `untaint` a resource by using `terraform untaint` and adding the specific resource.

## Terraform File Structures And Variables

Terraform will read all files within a directory. Standard practice is to use `main.tf` as the primary file within a directory and either split out things as neccessary. For instance, say we wanted to have a token or key in a file. We might not want to keep that in our `main.tf` or to make it reusable keep it in a seperate file and share our primary terraform.

So in our `main.tf` in our [files](./files) folder, we have our provider and make our token into a variable. During apply we could pass it as `terraform apply -var="linode_token={{token}}` or we could make a `variables.tf` and declare that variable. If we were going to use a CI/CD we could use a `.tfvars` file. This would allow us to ignore these files for upload keeping any sensitive data that might be compromising.

We can also add variables in the environment. To do so we would use `TF_VAR_{{variable_name}}`. As an example, we would run `export TF_VAR_linode_token={{token}}`.

Now that we know how to insert information, then how can we make our code cleaner. We can split out any specific resources into their own `.tf` files. So if we need to spin up an instance we can put it in it's own `instance.tf` file. When terraform is run in this directory it will pick up any files and partse them. This allows us to start split up our code allowing us to keep it easy to read. As our directory grows we can start to use modules to organize our files, but that's in another tutorial.

One more useful thing to know is that within HCL you can comment easily in files. Using either `#` for a line comment or `/* */` for block comments. This will make it easy to communicate with your team if working together or leave notes for yourself.
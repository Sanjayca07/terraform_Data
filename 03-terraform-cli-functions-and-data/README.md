# Terraform CLI, Functions, and Data

---

Here we'll be taking a look at various Terraform CLI commands, built in functions, and data modules. We'll be getting most of our information from the [Linode terraform provider](https://registry.terraform.io/providers/linode/linode/latest/docs) and [Terraform Documentation](https://www.terraform.io/docs/cli/index.html).

## Terraform CLI Commands

---

Say you've created a `.tf` files saved it and want to make sure that your formating is correct. Within the directory you can run `terraform fmt`. This will then automatically format the file. I've add a [folder](bad-format) that includes a [file](bad-format/main.tf) that you can run the command on to test.

Another useful command to do some testing is `terraform console`. This allows you to run various [expressions](https://www.terraform.io/docs/language/expressions/index.html)

If you are unsure if any current written terraform is valid such as formatting, functions, etc, then run `terraform validate`. This will validate that your current terraform is valid, but doesn't validate it has all the required parameters from your provider. 

## Terraform Functions

---

If we want to do some [functions](https://www.terraform.io/language/functions) within our terraform you can find all the linked documentation within the supplied link. Here are a few examples of what that would look like within code.

Here we do a join for the tags on Name. We're stating the join function using `join` ,then we need to designate what are we going to use as a seperator in the join which is the `-`. Now we can add in what items we want to joing within by supplying a map. Order matters if you wanted the project name first you'd put that `var.project` first and then `vault_ec2` second.

```HCL
resource "aws_instance" "tf_vault" {

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  key_name                    = var.key_name
  vpc_security_group_ids      = [module.security.terraform_sg.id]
  subnet_id                   = module.vpc.terraform_vpc_pub_subnet.id
  user_data                   = "${file(scripts/vault-install.sh)}"
  tags = {

    Name      = join("-", ["vault_ec2", var.project])
    Terraform = "true"

  }
}
```

Say a provider requires a specific field to be a json block. You could append like you do in bash scripting, but Terraform has some built in encoding options. Below is an example from [`jsonencode`](https://www.terraform.io/language/functions/jsonencode). Within the function it will pass anything as an encoded json block. There are other encoding blocks available such as `yaml` or `base64`.

```HCL
resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
```

## Terraform Data Blocks

---

Terraform has an ability to reference things outside the terraform state in providers. This is used by creating a data block. What we'll need to do is create a linode server manually within the linode UI.

1.) Login to Linode

2.) Click on Create -> Linode

3.) Select your image type and region

4.) For the plan just select Shared CPU -> Nanode 1 GB

5.) Update the Linode Label to `import-server`

6.) Enter a password

7.) Click Create Linode

Once the instance has been created you should be able to navigate to your [data-blocks] (data-blocks) folder within the repo and initialize it using `terraform init`. Add your `LINODE_TOKEN` either as a variable or within the file. Now if we run a `terraform plan` or `apply` because we have an output block it will show us it's public ip.
# Terraform Working With Multiple Resources

One of the core concepts of Terraform is being able to codify all of you infrastructure as code. This is the power of Terraform is that you can spin up and spin down resources in a matter of moments and create whole environments. In this section, we'll go through the basics of creating a whole environment from scratch. I'll be using a few different resoucres and some that will call to each other.

## Making Multiple Resources Using for_each and count

### `count`

First, we'll start with a count. If you are looking to spin up several webservers or databases, which will share similar tags, images, size, etc, then using a count would make it easy to spin up and down a large amount. Terraform will treat each of these as individual objects. You can use an index count to target specific resources in Terraform if you need to reference it elsewhere. For example, `lindoe_instance.web[0]` to select the first instance in the count.

We'll start by adding in a variable for the count. In this case, it will be web_servers and for now we'll set the default value to 2.

```HCL

variable "web_servers" {
  description = "Number of Web Servers"
  default = 2
  type = number
}

```

This is what we'll be using for an index to tell Terraform how many "web servers" we want to create. Now, let's create a stamdard instance resource block. Within the block there is now a `count = var.web_servers`. This will now create two instances. We can also use interpolation to add in `${count.index}` to add in the count number to our fields for  `label`, `root_pass`, and `tags`.

```HCL

resource "linode_instance" "web" {
    count = var.web_servers

    label = "${var.instance_label}-${count.index}"
    image = "linode/ubuntu18.04"
    region = "us-central"
    type = "g6-standard-1"
    root_pass = "terr4form-test-${count.index}"

    group = "webservers"
    tags = [ "terraform", "webserver-${count.index}" ]
    swap_size = 256
    private_ip = true
}

```

Now, we can run terraform plan and terraform apply and see that we've succesfully added two new webservers. Also, try updating the `var.web_servers` default value and running a new plan to see how this affects the current servers.

Once completed, feel free to run a `terraform destroy` to remove those two web servers before moving to our `for_each` section.

### `for_each`

Terraform also has the `for_each` function. This is a better option if you had similar resources that may share some of the same fields, but you want to customize individual aspects. In our example, we are going to do all of the values through our `for_each` function, but you could set some static values like normal. 

Another thing to note is that `for_each` treats the entire set of servers as a singular resource without an index. So if you change values it see a change to all of the current resources.

First, we'll add in our `variable "web_servers"`. Since, `linode_instance` has a number of fields that you can insert information into. In order for us to insert those values we'll us a map. Within that map object we can list all the names and types of values we are expecting.

```HCL

variable "web_servers" {

  description = "Names of web servers"
  type = map(object({

    label     = string
    image     = string
    region    = string
    type      = string
    root_pass = string

    group      = string
    tags       = list(string)
    swap_size  = number
    private_ip = bool

  }))

}

```

Now that we have those values set we have to add in our `default` field much like a standard variable. You can add as many maps as you like within the block. We'll start by adding a new web server.

```HCL

default = {
    "web" = {
      group      = "web-servers"
      image      = "linode/ubuntu18.04"
      label      = "web-server"
      private_ip = false
      region     = "us-central"
      root_pass  = "terr4form-test-web"
      swap_size  = 256
      tags = [
        "terraform",
        "db"
      ]
      type = "g6-standard-1"
    }
}

```

This will now create a single web server using all the values we applied. If you for instance wanted to add in a second server for the purposes of a db we could add a second map value. This whole block will look like the followin example.

```HCL

variable "web_servers" {

  description = "All of our servers"
  type = map(object({

    label     = string
    image     = string
    region    = string
    type      = string
    root_pass = string

    group      = string
    tags       = list(string)
    swap_size  = number
    private_ip = bool

  }))

  default = {
    "web" = {
      group      = "web-servers"
      image      = "linode/ubuntu18.04"
      label      = "web-server"
      private_ip = false
      region     = "us-central"
      root_pass  = "terr4form-test-web"
      swap_size  = 256
      tags = [
        "terraform",
        "db"
      ]
      type = "g6-standard-1"
    },
    "db" = {
      group      = "db-servers"
      image      = "linode/ubuntu20.04"
      label      = "db-server"
      private_ip = true
      region     = "us-east"
      root_pass  = "terr4form-test-db"
      swap_size  = 256
      tags = [
        "terraform",
        "db"
      ]
      type = "g6-standard-1"
    }
  }


}

```

Now you got your first map with multiple values we need to create a resource block that it will insert the values for each on listed. Much like a standard resource block you'll still need to list all the fields, but this time they will equal `each.value` and rather than a count we'll use `for_each = var.web_servers`.

```HCL

resource "linode_instance" "servers" {
  for_each = var.web_servers

  label     = each.value.label
  image     = each.value.image
  region    = each.value.region
  type      = each.value.type
  root_pass = each.value.root_pass

  group      = each.value.group
  tags       = each.value.tags
  swap_size  = each.value.swap_size
  private_ip = each.value.private_ip
}

```

If you now run a `terraform plan` and `terraform apply` you'll see that our new servers have been created with all the values specificed within their maps. Feel free to now add another map object and re-running apply to see how that affects the state of each resource.

## Multiple Resources

When building you Terraform, one of it's main abilities it to create all you infrastructure in one place. Many resources have dependencies that can be created and easily referenced in your code. For instance, say we want to spin up a simple website at the time we create our web server. If we look at [Linode's Terraform Registry](https://registry.terraform.io/providers/linode/linode/latest/docs) there is a resource called `linode_stackscript`. When you create a lindoe instance you can use one of these stack scripts as a part of start up.

Let's start by creating a `linode_stacksript` block listed on [this page](https://registry.terraform.io/providers/linode/linode/latest/docs/resources/stackscript). Below is our example and note the `script = templatefile(...)`. Within the directory templates/simple_website we're going to create a script file called `install.sh.tpl` and we're going to pass a variable `var.linode_label` as `"${web_server}"`.

```HCL

resource "linode_stackscript" "website" {
  label = "website"
  description = "Installs a simple website"
  script =   templatefile("${path.module}/templates/simple_website/install.sh.tpl", {"${web_server}" = "${var.linode_label}"})
  images = ["linode/ubuntu21.04", "linode/ubuntu18.04"]
  rev_note = "initial version"
}

```

Within our install.sh.tpl we are going to use the following script to set up our webserver.

```Shell

#!/bin/sh
# Update packages and Upgrade system
sudo apt-get update -y && sudo apt-get upgrade -y

## Install AMP
sudo apt-get install apache2 apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert -y

sudo apt-get install libapache2-mod-php5 php5 php5-common php5-curl php5-dev php5-gd php5-idn php-pear php5-imagick php5-mcrypt php5-mysql php5-ps php5-pspell php5-recode php5-xsl -y

sudo apt-get install mysql-server mysql-client libmysqlclient15.dev -y

sudo apt-get install phpmyadmin -y

sudo apt-get install apache2 libapache2-mod-php5 php5 mysql-server php-pear php5-mysql mysql-client mysql-server php5-mysql php5-gd -y

## TWEAKS and Settings
# Permissions
sudo chown -R www-data:www-data /var/www

# Enabling Mod Rewrite, required for WordPress permalinks and .htaccess files
sudo a2enmod rewrite
sudo php5enmod mcrypt

echo “Hello World from "${web_server}"” > /var/www/html/index.html

# Restart Apache
sudo service apache2 restart

```

Now let's create a variable called `linode_label` and we're going to create a resource block for a new `linode_instance`. Below is our resource block and variable block.

```HCL

variable "linode_label"{
    default = "web_server_01"
    type = string
}

resource "linode_instance" "web" {
    label = var.linode_label
    image = "linode/ubuntu21.04"
    region = "us-east"
    type = "g6-nanode-1"
    root_pass = "WebsiteServer2022!@#"

    group = "webservers"
    tags = [ "terraform", "webserver" ]
    swap_size = 256
    private_ip = true
    stackscript_id = linode_stackscript.website.id
}

```

Finally we're going to create a firewall to be used by our linode instance that we'll need to associate it to when created. Here we'll allow inbound on port 80 and set a default policy to drop any other traffic inboud. For our outbound policy we're going to set accept in order for our webserver to communicate out to the internet for updates and installing packages. Finally, there is a section called `linodes` and this is a list that we can associate multiple linode ids. We could look this up after the creation of the instance, but we want to automatically associate them. In order to do this we'll set it to `linode_instance.web.id`. Below is our example.

```HCL

resource "linode_firewall" "webserver_firewall" {
  label = "web_firewall"
  tags  = ["terraform", "webservers"]

  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy = "DROP"

  outbound_policy = "ACCEPT"

  linodes = [linode_instance.web.id]
}

```

Once everything has been created you can run a `terraform plan` to validate changes will go through, then a `terraform apply` to spin up all of our resources. With this you are now able to create multiple resources and assocaite them with each other for dependencies.

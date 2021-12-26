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
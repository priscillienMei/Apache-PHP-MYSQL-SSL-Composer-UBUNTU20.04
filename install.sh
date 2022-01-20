#!/bin/sh

sudo apt update 
sudo apt install apache2 libapache2-mod-fcgid software-properties-common python3-certbot-apache -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install php7.4 php7.4-fpm -y
sudo a2enmod actions fcgid alias proxy_fcgi ssl rewrite 

echo "<VirtualHost *:80>
    #ServerName www.example.com
    #ServerAlias www.example.com

    DocumentRoot /var/www/html
 
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>
 
    <FilesMatch \.php$>
        # 2.4.10+ can proxy to unix socket
        SetHandler \"proxy:unix:/var/run/php/php7.4-fpm.sock|fcgi://localhost\"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/000-default.conf

service apache2 restart


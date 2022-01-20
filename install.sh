#!/bin/sh

sudo apt update 
sudo apt install apache2 libapache2-mod-fcgid software-properties-common python3-certbot-apache unzip curl -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install php7.4 php7.4-fpm php7.4-intl libapache2-mod-php7.4 php7.4-mysql php7.4-curl php7.4-xml php7.4-mcrypt php7.4-imagick -y
sudo a2enmod actions fcgid alias proxy_fcgi ssl rewrite 

cd ~
curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php');  exit; } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

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

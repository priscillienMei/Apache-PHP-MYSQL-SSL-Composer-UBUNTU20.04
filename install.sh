#!/bin/sh

sudo apt update
sudo apt install apache2 libapache2-mod-fcgid software-properties-common python3-certbot-apache unzip curl -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo a2enmod actions fcgid alias proxy_fcgi ssl rewrite

#PHP VERSION CHOICE
while true; do
    read -p "please choose php version you want to install (7.4 or 8) ? " php
    case $php in
        [7.4]* ) sudo apt install php7.4 php7.4-fpm php7.4-intl libapache2-mod-php7.4 php7.4-mysql php7.4-curl php7.4-xml php7.4-mcrypt php7.4-imagick php7.4-gd libapache2-mod-php7.4 php7.4-mysql -y;  break;;
        [8]* ) sudo apt install php8 php8-fpm php8-intl libapache2-mod-php8 php8-mysql php8-curl php8-xml php8-mcrypt php8-imagick php8-gd libapache2-mod-php8 php8-mysql-y; break;;
        * ) echo "Please answer 7.4 or 8";;
    esac
done

# INSTALL COMPOSER ?
while true; do
    read -p "Do you wish to install Composer? " composer
    case $composer in
        [Yy]* ) cd ~ ; curl -sS https://getcomposer.org/installer -o composer-setup.php; HASH=`curl -sS https://composer.github.io/installer.sig`; php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php');  exit; } echo PHP_EOL;"; sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
 break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes/Y/y or no/N/n.";;
    esac
done

# INSTALL MYSQL ?
while true; do
    read -p "Do you wish to install mysql? " mysql
    case $mysql in
        [Yy]* ) apt install mysql-server -y; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes/Y/y or no/N/n.";;
    esac
done

# Secure MYSQL ?
while true; do
    read -p "Do you wish to secure mysql? " mysql
    case $mysql in
        [Yy]* )
                read -s -p "New Password: " password; echo ; read -s -p "New Password (again): " password2; echo;
                while [ "$password" != "$password2" ];
                    do
                        echo
                        echo "Please try again"
                        read -s -p "Password: " password
                        echo
                        read -s -p "Password (again): " password2
                        echo
                        mysql -e "UPDATE mysql.user SET Password = PASSWORD('$password') WHERE User = 'root'"
                        mysql -e "DROP USER ''@'localhost'"
                        mysql -e "DROP USER ''@'$(hostname)'"
                        mysql -e "DROP DATABASE test"
                        mysql -e "FLUSH PRIVILEGES"
                  done;
break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes/Y/y or no/N/n.";;
    esac
done

# EDIT DEFAULT VHOST
while true; do
    read -p "Do you wish to add php to default vhost? " dvhost
    case $dvhost in
        [Yy]* )
echo "Add php support on default Virtualhost"
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
        SetHandler \"proxy:unix:/var/run/php/php$php-fpm.sock|fcgi://localhost\"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
" > /etc/apache2/sites-available/000-default.conf
break;;
       [Nn]* ) break;;
       * ) echo "Please answer yes/Y/y or no/N/n.";;
   esac
done

service apache2 restart

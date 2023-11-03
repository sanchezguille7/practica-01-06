#!/bin/bash

#Muestra todos los comandos que se van ejecutadno
set -ex

# Actualizamos los repositorios
apt update

# actualizamos los paquetes 
#apt upgrade -y

#Incluimos las variables del archivo .env
source .env

#Eliminamos descargar previas del codigo fuente
rm -rf /tmp/latest.zip

#descargamos el codigo fuente
wget https://wordpress.org/latest.zip -P /tmp

# Descargamos unzip
apt install unzip -y

# descomprimimos el archivo
unzip -u /tmp/latest.zip -d /tmp/

# Eliminamos instalaciones previas de Wordpress en /var/www/html
rm -rf /var/www/html/*

#movemos el contenido de /tmp/wordpress a /var/www/html
mv -f /tmp/wordpress/* /var/www/html

#Creamos la base de datos y el usuario de la base de datos
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

# Renombramos el archivo de configuracion de WordPress
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Configuramos la variables del archivo de configuracion de WordPress
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php

# Cambiamos el dueño
chown -R www-data:www-data /var/www/html/
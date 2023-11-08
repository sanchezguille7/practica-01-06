#!/bin/bash

#Muestra todos los comandos que se van ejecutadno
set -ex

# Actualizamos los repositorios
apt update

# actualizamos los paquetes 
#apt upgrade -y

#instalamos el servidor web Apache
apt install apache2 -y

# 
cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf

#Instalar  el sistema gestor de datos MySQL
apt install mysql-server -y

#DB_USER=usuario
#DB_PASSWD=contraseña

#mysql -u $DB_USER -p$DB_PASSWD < ../sql/database.sql

#Instalamos php
sudo apt install php libapache2-mod-php php-mysql -y

#Reiniciamos servicio
systemctl restart apache2

# Modificamos el propietario
chown -R www-data:www-data /var/www/html
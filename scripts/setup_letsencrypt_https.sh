#!/bin/bash

#Muestra todos los comandos que se van ejecutadno
set -x

# Actualizamos los repositorios
apt update

# Actualizamos los paquetes 
#apt upgrade -y

# Ponemos las variables del archivo .env
source .env

# Instalamos y actualizamos Snap
snap install core
snap refresh core

# Eliminamos cualquier instalacion previa de certbot con apt
apt remove certbot

# Instalamos la aplicacion certbot 
snap install --classic certbot

# Creamos una alias para el comando certbot.
ln -fs /snap/bin/certbot /usr/bin/certbot 

# Obtenemos el certificado y configuramos el servidor web Apache
# Ejecutamos el comando Certbot
certbot --apache -m $CERTIFICATE_EMAIL --agree-tos --no-eff-email -d $CERTIFICATE_DOMAIN --non-interactive
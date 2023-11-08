#!/bin/bash

#Muestra todos los comandos que se van ejecutadno
set -ex

# Los pasos que hay que llevar a cabo para instalar WordPress en su propio directorio
source .env

# Descargamos la última versión de WordPress con el comando wget.
wget http://wordpress.org/latest.zip -P /tmp

# Descomprimimos el archivo .zip que acabamos de descargar con el comando tar.
unzip -u /tmp/latest.zip -d /tmp/

# Eliminamos instalaciones previas de Wordpress en /var/www/html
rm -rf /var/www/html/wordpress/

# Creamos la carpeta Wordpress
mkdir -p /var/www/html/wordpress/

#movemos el contenido de /tmp/wordpress a /var/www/html
mv -f /tmp/wordpress/* /var/www/html/wordpress

# Creamos la base de datos y el usuario de la base de datos
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

# Renombramos el archivo de configuracion de WordPress
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

# Configuramos la variables del archivo de configuracion de WordPress
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wordpress/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wordpress/wp-config.php

# Configuramos las variables WP_SITEURL y WP_HOME del archivo de configuración wp-config.php.
sed -i "/DB_COLLATE/a define('WP_SITEURL', 'https://$CERTIFICATE_DOMAIN/wordpress');" /var/www/html/wordpress/wp-config.php
sed -i "/WP_SITEURL/a define('WP_HOME', 'https://$CERTIFICATE_DOMAIN');" /var/www/html/wordpress/wp-config.php

# Copiamos el archivo /var/www/html/wordpress/index.php a /var/www/html.
cp /var/www/html/wordpress/index.php /var/www/html

# Editamos el archivo index.php.
sed -i "s#wp-blog-header.php#wordpress/wp-blog-header.php#" /var/www/html/wordpress/index.php 

# Ahora tendremos que crear un archivo .htaccess en el directorio /var/www/html
cp ../htaccess/.htaccess /var/www/html/

# Habilitamos el módulo mod_rewrite de Apache.
a2enmod rewrite

# Reiniciamos el servicio apache
systemctl restart apache2
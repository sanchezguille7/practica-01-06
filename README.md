# Práctica 01-06
En esta practica aprenderemos a crear una pagina de WordPress desde cero. Tendremos 3 directorios, el directorio 1 **scripts**, el directorio 2 **conf** y el directorio 3 **htaccess**. Dentro de **scripts** hay 4 scripts y un archivo .env que son: 
	- **deploy_wordpress_own_directory.sh:** Automatización del proceso de instalación de WordPress sobre su propio directorio.
	- **deploy_wordpress_root_directory.sh:** Automatización del proceso de instalación de WordPress sobre el directorio raíz /var/www/html.
	- **setup_letsencrypt_https.sh:** Automatización del proceso de solicitar un certificado SSL/TLS de Let’s Encrypt y configurarlo en el servidor web **Apache**.
	- **install_lamp.sh:** Automatización del proceso de instalación de la pila LAMP.
  - **.env:** Este archivo contiene todas las variables de configuración que se utilizarán en los scripts anteriores.

## install_lamp.sh
Muestra todos los comandos que se van ejecutando
`set -ex`

Actualizamos los repositorios
`apt update`

Actualizamos los paquetes 
`apt upgrade -y`

Instalamos el servidor web **Apache**
`apt install apache2 -y`

Copiamos la configuración predeterminada del servidor
`cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf`

Instalamos el sistema gestor de datos **MySQL**
`apt install mysql-server -y`

Descomentar las siguientes líneas y asignar valores a DB_USER y DB_PASSWD
#DB_USER=usuario
#DB_PASSWD=contraseña
`mysql -u $DB_USER -p$DB_PASSWD < ../sql/database.sql`

Instalamos **PHPMyAdmin** y el módulo para **Apache**
`sudo apt install php libapache2-mod-php php-mysql -y`

Reiniciamos el servicio **Apache**
`systemctl restart apache2`

Modificamos el propietario de los archivos en el directorio **HTML**
`chown -R www-data:www-data /var/www/html`



## setup_letsencrypt_https.sh
Muestra todos los comandos que se van ejecutando

    set -ex

Actualizamos los repositorios

    apt update

Actualizamos los paquetes 

    apt upgrade -y

Ponemos las variables del archivo .env

    source .env

Instalamos y actualizamos **Snap**

    snap install core
    snap refresh core

Eliminamos cualquier instalación previa de **certbot** con apt

    apt remove certbot

Instalamos la aplicación **Certbot** 

    snap install --classic certbot

Creamos un alias para el comando **Certbot**

    ln -fs /snap/bin/certbot /usr/bin/certbot

Obtenemos el certificado y configuramos el servidor web **Apache**
Ejecutamos el comando **Certbot**

    certbot --apache -m $CERTIFICATE_EMAIL --agree-tos --no-eff-email -d $CERTIFICATE_DOMAIN --non-interactive




## deploy_wordpress_root_directory.sh
Muestra todos los comandos que se van ejecutando

    set  -ex

Incluimos las variables del archivo **.env**

    source .env

Eliminamos descargas previas del código fuente

    rm -rf /tmp/latest.zip

Descargamos el código fuente

    wget https://wordpress.org/latest.zip -P /tmp

Instalamos **unzip**

    apt install unzip -y

Descomprimimos el archivo

    unzip -u /tmp/latest.zip -d /tmp/

Eliminamos instalaciones previas de **WordPress** en */var/www/html*

    rm -rf /var/www/html/*

Movemos el contenido de */tmp/wordpress* a */var/www/html*

    mv -f /tmp/wordpress/* /var/www/html

Creamos la base de datos y el usuario de la base de datos

    mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
    mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
    mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
    mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
    mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

Renombramos el archivo de configuración de **WordPress**

    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

Configuramos las variables del archivo de configuración de **WordPress**

    sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
    sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
    sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
    sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php

Cambiamos el dueño

    chown -R www-data:www-data /var/www/html/

Ahora tendremos que crear un archivo **.htaccess** en el directorio */var/www/html*

    cp ../htaccess/.htaccess /var/www/html/

Habilitamos el módulo **mod_rewrite** de **Apache**

    a2enmod rewrite

Reiniciamos el servicio **Apache**

    systemctl restart apache2




## deploy_wordpress_own_directory.sh
Muestra todos los comandos que se van ejecutando

    set  -ex
    
Los pasos que hay que llevar a cabo para instalar **WordPress** en su propio directorio

    source  .env
    
Descargamos la última versión de **WordPress** con el comando **wget.**

    wget  http://wordpress.org/latest.zip  -P  /tmp

  

Descomprimimos el archivo **.zip** que acabamos de descargar con el comando **unzip**.

    unzip -u /tmp/latest.zip -d /tmp/

  

Eliminamos instalaciones previas de **Wordpress** en */var/www/html*

    rm  -rf  /var/www/html/wordpress/

  

Creamos la carpeta **Wordpress**

    mkdir  -p  /var/www/html/wordpress/

  

Movemos el contenido de */tmp/wordpress* a */var/www/html*

    mv  -f  /tmp/wordpress/*  /var/www/html/wordpress

  

Creamos la base de datos y el usuario de la base de datos

    mysql  -u  root  <<<  "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
    
    mysql  -u  root  <<<  "CREATE DATABASE $WORDPRESS_DB_NAME"
    
    mysql  -u  root  <<<  "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
    
    mysql  -u  root  <<<  "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
    
    mysql  -u  root  <<<  "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

  

Renombramos el archivo de configuración de **WordPress**

    cp  /var/www/html/wordpress/wp-config-sample.php  /var/www/html/wordpress/wp-config.php

  

Configuramos la variables del archivo de configuración de **WordPress**

    sed  -i  "s/database_name_here/$WORDPRESS_DB_NAME/"  /var/www/html/wordpress/wp-config.php

    sed  -i  "s/username_here/$WORDPRESS_DB_USER/"  /var/www/html/wordpress/wp-config.php
    
    sed  -i  "s/password_here/$WORDPRESS_DB_PASSWORD/"  /var/www/html/wordpress/wp-config.php
    
    sed  -i  "s/localhost/$WORDPRESS_DB_HOST/"  /var/www/html/wordpress/wp-config.php

  

Configuramos las variables **WP_SITEURL** y **WP_HOME** del archivo de configuración *wp-config.php*.

    sed  -i  "/DB_COLLATE/a define('WP_SITEURL', 'https://$CERTIFICATE_DOMAIN/wordpress');"  /var/www/html/wordpress/wp-config.php
    
    sed  -i  "/WP_SITEURL/a define('WP_HOME', 'https://$CERTIFICATE_DOMAIN');"  /var/www/html/wordpress/wp-config.php

  

Copiamos el archivo */var/www/html/wordpress/index.php* a */var/www/html*.

    cp  /var/www/html/wordpress/index.php  /var/www/html

  

Editamos el archivo *index.php*.

    sed  -i  "s#wp-blog-header.php#wordpress/wp-blog-header.php#"  /var/www/html/wordpress/index.php

  

Ahora tendremos que crear un archivo **.htaccess** en el directorio */var/www/html*

    cp  ../htaccess/.htaccess  /var/www/html/

  

Habilitamos el módulo **mod_rewrite** de **Apache**.

    a2enmod  rewrite

  

Reiniciamos el servicio **Apache**

    systemctl  restart  apache2

## .env
Configuramos las variables

    WORDPRESS_DB_NAME=worpress
    WORDPRESS_DB_USER=wp_user
    WORDPRESS_DB_PASSWORD=wp_pass
    WORDPRESS_DB_HOST=localhost
    
    IP_CLIENTE_MYSQL=localhost
    
    CERTIFICATE_EMAIL=guilleemail@demo.es
    CERTIFICATE_DOMAIN=practica01-06gsm.hopto.org

## .htaccess

    # BEGIN WordPress
    <IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteRule ^index\.php$ - [L]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.php [L]
    </IfModule>
    # END WordPress
**RewriteEngine On:** Habilita el motor de reesscritura de URLs.
**RewriteBase /:** Define la ruta base que se utilizará para las reglas de reescritura.
**RewriteRule ^index\.php$ - [L]:** Esta regla indica que si la petición que se está evaluando coincide con *index.php* entonces no se realiza ninguna acción. El carácter **-** indica que no se hará ninguna acción y el flag **[L]** (Last) indica que será la última regla que se aplique en esta evaluación.
**RewriteCond %{REQUEST_FILENAME} !-f:** Esta condición comprueba si la petición que se está evaluando no es un archivo. Si no lo es, entonces se aplica la siguiente regla de reescritura.
**RewriteCond %{REQUEST_FILENAME} !-d**: Esta condición comprueba si la petición que se está evaluando no es un directorio. Si no lo es, entonces se aplica la siguiente regla de reescritura.
**RewriteRule . /index.php [L]:** Esta regla se aplicará cuando se cumplan las dos condiciones anteriores. Si la petición no es un archivo y no es un directorio, entonces se hace una redirección a *index.php*.

## 000-default.conf
Para que el servidor web **Apache** pueda leer el archivo **.htaccess** tendremos que configurar la directiva **AllowOverride** como `AllowOverride All`. Esta configuración se tendrá que realizar en el archivo de configuración del **VirtualHost** de **Apache**.
  

      <VirtualHost *:80>
        #ServerName www.example.com
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        DirectoryIndex index.php index.html
        <Directory "/var/www/html">
        AllowOverride All
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
        </VirtualHost>
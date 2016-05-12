#!/bin/bash
echo  "Digite o domÃ­nio do virtual host:"
read  DOMINIO
echo  "Digite o ip para esse domÃ­nio. No caso de compartilhado digite *:"
read IP
echo  "Digite o nome de usuario para esse domÃ­nio:"
read USUARIO

#cria o usuario
echo "Criando o usuario $USUARIO"
adduser $USUARIO

#cria pastas do virtual host
echo "Criando as pastas do usuario $USUARIO"
mkdir /home/$USUARIO/www /home/$USUARIO/logs /home/$USUARIO/ssl

./cert.sh $DOMINIO

mv $DOMINIO* /home/$USUARIO/ssl

#Aplica permissÃµes
echo "Aplicando permissÃµes para o usuario $USUARIO"
chown -R $USUARIO:$USUARIO /home/$USUARIO/
chmod -R 755 /home/$USUARIO

#cria virtual host no nginx
echo "
upstream fpm_backend_$USUARIO {
 server unix:/usr/share/$USUARIO.sock;
}

server {
    # Listen on port 80 as well as post 443 for SSL connections.
    listen $IP:8000;
    listen $IP:443 ssl;

    server_name  $DOMINIO www.$DOMINIO;

    # Specify path to your SSL certificates.
    ssl_certificate /home/$USUARIO/ssl/$DOMINIO.crt;
    ssl_certificate_key /home/$USUARIO/ssl/$DOMINIO.key;

    # Path to the files in which you wish to
    # store your access and error logs.
    access_log /home/$USUARIO/logs/access_log;
    error_log /home/$USUARIO/logs/error_log;

    # If the site is accessed via yourdomain.com
    # automatically redirect to www.yourdomain.com.
    if (\$host = '$DOMINIO' ) {
        rewrite ^/(.*)$ http://www.$DOMINIO/$1 permanent;
    }

    root /home/$USUARIO/www;

   
    location / {
        index index.html index.php;
        try_files \$uri \$uri/ @handler;
    }




	location /phpmyadmin {
               root /usr/share/;
               index index.php index.html index.htm;
               location ~ ^/phpmyadmin/(.+\.php)$ {
                       try_files \$uri =404;
                       root /usr/share/;
                       fastcgi_pass unix:/usr/share/$USUARIO.sock;
                       fastcgi_index index.php;
                       fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                       include /etc/nginx/fastcgi_params;
               }

               location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
                       root /usr/share/;
               }

        }

        location /phpMyAdmin {
               rewrite ^/* /phpmyadmin last;
        }


 # Deny access to specific directories no one
    # in particular needs access to anyways.
    location /app/ { deny all; }
    location /includes/ { deny all; }
    location /lib/ { deny all; }
    location /media/downloadable/ { deny all; }
    location /pkginfo/ { deny all; }
    location /report/config.xml { deny all; }
    location /var/ { deny all; }

    # Allow only those who have a login name and password
    # to view the export folder. Refer to /etc/nginx/htpassword.
    location /var/export/ {
        auth_basic \"Restricted\";
        auth_basic_user_file htpasswd;
        autoindex on;
    }
 # Deny all attempts to access hidden files
    # such as .htaccess, .htpasswd, etc...
    location ~ /\. {
         deny all;
         access_log off;
         log_not_found off;
    }

# This redirect is added so to use Magentos
    # common front handler when handling incoming URLs.
    location @handler {
        rewrite / /index.php;
    }
 # Forward paths such as /js/index.php/x.js
    # to their relevant handler.
    location ~ (.+\.php)/ {
        rewrite ^(.*.php)/ \$1 last;
    }

# Handle the exectution of .php files.
    location ~ (.+\.php)$ {
        expires off;
        fastcgi_pass fpm_backend_$USUARIO;

        fastcgi_connect_timeout 9m;
        fastcgi_send_timeout 9m;
        fastcgi_read_timeout 9m;

        #fastcgi_param HTTPS \$fastcgi_https;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param MAGE_RUN_CODE default;
        fastcgi_param MAGE_RUN_TYPE store;
        include fastcgi_params;
    }
}" > /etc/nginx/conf.d/$DOMINIO.conf

#cria virtualhost no php-fpm
echo "[$USUARIO]
listen = /usr/share/$USUARIO.sock
user = $USUARIO
group = $USUARIO
listen.mode = 0666
request_slowlog_timeout = 5s
slowlog = /home/$USUARIO/logs/slowlog.log
listen.allowed_clients = 127.0.0.1
pm = static
pm.max_children = 15
;pm.start_servers = 2
;pm.min_spare_servers = 1
;pm.max_spare_servers = 3
pm.max_requests = 500
listen.backlog = -1
pm.status_path = /status
request_terminate_timeout = 120s
rlimit_files = 131072
rlimit_core = unlimited
catch_workers_output = yes
env[HOSTNAME] = \$HOSTNAME
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp" > /etc/php-fpm.d/$USUARIO.conf

#Configurando permissÃ£o para pasta do usuario para o vsftpd
chmod 'a-w' /home/$USUARIO

#cria a base de dados
MyUSER="enfratec"

echo  "Digite a senha do usuÃ¡rio root do mysql"
read MyPASS

HostName="enfratec.c4rm1cm3aare.us-west-2.rds.amazonaws.com"

dbName=$USUARIO
dbUser=$USUARIO

echo  "Digite uma senah para o novo usuario"
read dbPass

mysql -u $MyUSER -h $HostName -p$MyPASS -Bse "CREATE DATABASE $dbUser;"
mysql -u $MyUSER -h $HostName -p$MyPASS -Bse "GRANT ALL ON ${dbUser}.* to '$dbName'@'localhost' identified by '$dbPass';"
mysql -u $MyUSER -h $HostName -p$MyPASS -Bse "GRANT ALL ON ${dbUser}.* to '$dbName'@'%' identified by '$dbPass';"



#Reiniciando servidores
echo "Reiniciando NGINX"
service nginx restart
echo "Reiniciando PHP5-FPM"
service php-fpm restart

#configurando arquivos host
echo "127.0.0.1 $DOMINIO" >> /etc/hosts
echo "127.0.0.1 www.$DOMINIO" >> /etc/hosts


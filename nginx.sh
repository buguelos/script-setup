#!/bin/bash
echo  "Digite a quantidade de nÃºcleos do sistema"
read NUCLEOS

echo "user  nginx;
      worker_processes  $NUCLEOS;

      error_log  /var/log/nginx/error.log warn;
      pid        /var/run/nginx.pid;


      events {
          worker_connections  1024;
      }


      http {
          sendfile on;
          keepalive_timeout 5;
          server_names_hash_bucket_size 64;
          types_hash_max_size 2048;
          include /etc/nginx/mime.types;
          default_type application/octet-stream;

          log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                            '$status $body_bytes_sent "$http_referer" '
                            '"$http_user_agent" "$http_x_forwarded_for"';

          access_log  off;

          map \$scheme \$fastcgi_https {
                  default off;
                  https on;
          }

          gzip on;
          gzip_disable 'msie6';
          gzip_vary on;
          gzip_proxied any;
          gzip_comp_level 5;
          gzip_buffers 16 8k;
          gzip_http_version 1.1;
          gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

          include /etc/nginx/conf.d/*.conf;
      }" > /etc/nginx/nginx.conf

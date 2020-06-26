#!/bin/bash


if [ "$#" -eq 1 ]; then
  DOMAIN=$1
else
  echo "Usage: $0 domain-name"
  exit -1
fi

docker-compose down
rm -Rf server.key server.crt docker-compose.yml default.conf

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=ES/ST=Madrid/L=Tres Cantos/O=Thales Alenia Space/CN=$DOMAIN" -keyout server.key -out server.crt
tee docker-compose.yml <<EOF
version: "2.4"
services:
  nginx:
    image: "nginx:1.17.9"
    container_name: "nginx"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./default.conf:/etc/nginx/conf.d/default.conf
      - ./server.crt:/etc/nginx/ssl/server.crt
      - ./server.key:/etc/nginx/ssl/server.key
EOF
tee default.conf <<EOF
server {
    listen       80;
    listen       443 ssl;
    server_name  _;
    ssl_certificate "/etc/nginx/ssl/server.crt";
    ssl_certificate_key "/etc/nginx/ssl/server.key";
    #ssl_protocols TLSv1.2 TLSv1.3;
    #ssl_prefer_server_ciphers on;
    #ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
docker-compose up -d
docker logs -f nginx
#curl http://<DOMAIN>
#curl http://predex.duckdns.org
#curl http://predex1.francecentral.cloudapp.azure.com
#curl -k https://<DOMAIN>
#curl -k http://predex.duckdns.org
#curl -k http://predex1.francecentral.cloudapp.azure.com
#https://www.ssllabs.com/ssltest/

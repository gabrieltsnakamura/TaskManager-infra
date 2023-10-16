#!/bin/bash

sudo su

apt-get update
apt-get install nginx -y
systemctl enable nginx
systemctl start nginx

cat <<EOF > index.html
<!DOCTYPE html>
<html>
  <head>
    <title>200 OK</title>
  </head>
  <body>
    <h1>200 OK</h1>
    <p>This page returns a 200 status code.</p>
  </body>
</html>
EOF

cp index.html /var/www/html/
chown www-data:www-data /var/www/html/index.html
chmod 644 /var/www/html/index.html

apt-get update
apt install ruby-full -y
apt install wget -y
cd /home/ubuntu
wget https://aws-codedeploy-sa-east-1.s3.sa-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto


systemctl start codedeploy-agent
systemctl enable codedeploy-agent


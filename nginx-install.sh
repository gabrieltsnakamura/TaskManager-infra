sudo apt-get update
sudo apt-get install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

aws s3 cp s3://taskmanager-bucket/bin/taskmanager_app.zip /var/www/html/taskManager/

unzip /var/www/html/taskManager/taskmanager_app.zip -d /var/www/html/taskManager/
mv /var/www/html/taskManager/dist/taskmanager/* /var/www/html/taskManager/
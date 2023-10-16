unzip taskmanager_app.zip
mkdir /var/www/html/taskmanager_app
cd taskmanager_app/dist/taskmanager_app
cp -r * /var/www/html/taskmanager_app
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html/taskmanager;

    # Add index.php to the list if you are using PHP
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        index index.html
        try_files $uri $uri/ /index.html;
    }

    error_page 404 /index.html;
}
EOF
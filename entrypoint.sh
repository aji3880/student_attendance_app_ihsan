#!/bin/sh
set -e

# Buat default Nginx config jika belum ada
if [ ! -f /etc/nginx/conf.d/default.conf ]; then
  cat <<EOF > /etc/nginx/conf.d/default.conf
server {
    listen       8080;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html;
        try_files \$uri /index.html;
    }
}
EOF
fi

# Jalankan nginx di foreground
exec nginx -g 'daemon off;'

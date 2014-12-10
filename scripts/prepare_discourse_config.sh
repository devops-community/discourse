#!/bin/bash

# Load the variables from the ENV
WORKDIR=$WORKDIR
ADMIN_EMAIL=$ADMIN_EMAIL

# DB details
DB_USER=$DB_USER
DB_PASS=$DB_PASS
DB_NAME=$DB_NAME
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT

DOMAIN=$DOMAIN

# Email connect
SMTP_ADDRESS=$SMTP_ADDRESS
SMTP_PORT=$SMTP_PORT
SMTP_DOMAIN=$SMTP_DOMAIN
SMTP_USER_NAME=$SMTP_USER_NAME
SMTP_PASSWORD=$SMTP_PASSWORD



if [ -z "$WORKDIR" ]; then
    echo "WORKDIR is missing. Exiting" >&2
    exit 1
elif [ ! -d "$WORKDIR" ]; then
    echo "Folder $WORKDIR does not exist. Exiting" >&2
    exit 1
fi

if [ -z "$ADMIN_EMAIL" ]; then
    echo "Administrator email is missing. You can specify several emails comma seperated. Exiting" >&2
    exit 1
fi

# Set defaults
[ -z "$DB_HOST" ] && DB_HOST='127.0.0.1'
[ -z "$DB_PORT" ] && DB_PORT=5432

[ -z "$DOMAIN" ] && DOMAIN='discourse.example.com'

[ -z "$SMTP_ADDRESS" ] && SMTP_ADDRESS='127.0.0.1'
[ -z "$SMTP_PORT" ] && SMTP_PORT=25
[ -z "$SMTP_DOMAIN" ] && SMTP_DOMAIN=
[ -z "$SMTP_USER_NAME" ] && SMTP_USER_NAME=
[ -z "$SMTP_PASSWORD" ] && SMTP_PASSWORD=


cd $WORKDIR
if [ ! -d config ]; then
    echo "$WORKDIR/config folder is missing. Exiting" >&2
    exit 1
fi

cd config
if [ -e discourse.conf ]; then
    echo "discourse.conf folder already existing. Updating parameters."
    # Handle DB related config
    sed -i.bak "s/^\s*db_host\s*=.*$/db_host = '$DB_HOST'/g" discourse.conf
    sed -i.bak "s/^\s*db_port\s*=.*$/db_port = '$DB_PORT'/g" discourse.conf
    sed -i.bak "s/^\s*db_username\s*=.*$/db_username = '$DB_USER'/g" discourse.conf
    sed -i.bak "s/^\s*db_password\s*=.*$/db_password = '$DB_PASS'/g" discourse.conf
    sed -i.bak "s/^\s*db_name\s*=.*$/db_name = '$DB_NAME'/g" discourse.conf
    # Handle admins / domain / emails
    sed -i.bak "s/^\s*developer_emails\s*=.*$/developer_emails = '$ADMIN_EMAIL'/g" discourse.conf
    sed -i.bak "s/^\s*hostname\s*=.*$/hostname = '$DOMAIN'/g" discourse.conf

    sed -i.bak "s/^\s*smtp_address\s*=.*$/smtp_address = '$SMTP_ADDRESS'/g" discourse.conf
    sed -i.bak "s/^\s*smtp_port\s*=.*$/smtp_port = '$SMTP_PORT'/g" discourse.conf
    sed -i.bak "s/^\s*smtp_domain\s*=.*$/smtp_domain = '$SMTP_DOMAIN'/g" discourse.conf
    sed -i.bak "s/^\s*smtp_user_name\s*=.*$/smtp_user_name = '$SMTP_USER_NAME'/g" discourse.conf
    sed -i.bak "s/^\s*smtp_password\s*=.*$/smtp_password = '$SMTP_PASSWORD'/g" discourse.conf
else
    cp discourse_quickstart.conf discourse.conf
    cat >> discourse.conf << EOF
# Set Database details
db_host = '$DB_HOST'
db_port = '$DB_PORT'
db_username = '$DB_USER'
db_password = '$DB_PASS'
db_name = '$DB_NAME'
# Set Admin emails
developer_emails = '$ADMIN_EMAIL'
# Set Domain
hostname = '$DOMAIN'
# Set SMTP details
smtp_address = '$SMTP_ADDRESS'
smtp_port = '$SMTP_PORT'
smtp_domain = '$SMTP_DOMAIN'
smtp_user_name = '$SMTP_USER_NAME'
smtp_password = '$SMTP_PASSWORD'
EOF
fi

# Dirty hack to update the nginx config
cp nginx.sample.conf nginx.devo.ps.conf
cat >> nginx.devo.ps.conf << EOF

upstream discourse-http {
  server 127.0.0.1:3000;
}

EOF

# Update the proxy_pass setup
sed -i.bak "s/proxy_pass\s*http:\/\/discourse\s*;/proxy_pass http:\/\/discourse-http;/g" nginx.devo.ps.conf
sed -i.bak "s/server_name\s*.*/server_name $DOMAIN;/g" nginx.devo.ps.conf
sed -i.bak "s/proxy_cache_path\s*\/var\/nginx\/cache\s*/proxy_cache_path \/var\/lib\/nginx\/cache /g" nginx.devo.ps.conf

# Now preparing the nginx config
sudo cp -a nginx.devo.ps.conf /etc/nginx/sites-available/discourse
sudo rm /etc/nginx/sites-enabled/discourse
sudo ln -s ../sites-available/discourse /etc/nginx/sites-enabled/discourse

# Reload nginx config
sudo service nginx reload


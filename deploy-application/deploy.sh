#!/bin/bash

# Use in Amazon Linux 2023

# Set up ENV
DB_HOST="your-rds-endpoint"
DB_NAME="awsfcjuser"
DB_USER="fcjdntu"
DB_PASS="letmein12345"

# Update packages
sudo yum update -y

# Download required dependencies
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
sudo yum install git

function checkCommand() {
  if command -v $1 &> /dev/null; then
    echo "$1 installation found"
  else
    echo "$1 installation not found. Please install $1."
    exit 1
  fi
}

## Setup ENV for Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

## Check nvm
checkCommand nvm

## Check git
checkCommand git

## Install Node (NPM is included)
nvm install 20

## Check node
checkCommand node

## Check npm
checkCommand npm

# Install MySQL Client
sudo dnf install mariadb105

## Check mysql
checkCommand mysql

## Run sql script and insert data
mysql -h $DB_HOST -u $DB_USER $DB_NAME -p < init.sql

# Change directory to HOME
cd ~

# Clone Repository
git clone https://github.com/First-Cloud-Journey/000004-EC2.git

## Go to dir
cd 000004-EC2

## Install Node JS dependencies
npm install

## Install pm2
npm install -g pm2

## Check pm2
checkCommand pm2

## To ensure node server run properly, add new .env file
cat << EOF > .env
DB_HOST=$DB_HOST
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASS=$DB_PASS
EOF

cat << EOF >> ~/.bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

## Start server
pm2 start app.js

## Add startup script to systemd
sudo env "PATH=$PATH:/home/$whoami/.nvm/versions/node/$(node -v)/bin /home/$whoami/.nvm/versions/node/$(node -v)/lib/node_modules/pm2/bin/pm2 startup systemd -u $whoami --hp /home/$whoami"

## Save startup
pm2 save

echo "YOUR SERVER IS READY"
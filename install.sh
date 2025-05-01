#!/bin/bash

# Підключення загальних функцій та змінних з репозиторію
source <(curl -s https://raw.githubusercontent.com/R1M-NODES/utils/master/common.sh) || { echo "Failed to load common.sh"; exit 1; }

# Відображення логотипу
printLogo

#!/bin/bash

# Prompting for values of each variable
read -p "Enter your FORTA passphrase:(a-z, A-Z, 0-9) with at least 12 characters) " FORTA_PASSPHRASE
read -p "Enter your FORTA owner address: " FORTA_OWNER_ADDRESS
read -p "Enter the FORTA RPC URL: " FORTA_RPC_URL
read -p "Enter the FORTA Proxy RPC URL: " FORTA_PROXY_RPC_URL

# Adding them to .bash_profile
echo "export FORTA_PASSPHRASE=$FORTA_PASSPHRASE" >> ~/.bash_profile
echo "export FORTA_OWNER_ADDRESS=$FORTA_OWNER_ADDRESS" >> ~/.bash_profile
echo "export FORTA_RPC_URL=$FORTA_RPC_URL" >> ~/.bash_profile
echo "export FORTA_PROXY_RPC_URL=$FORTA_PROXY_RPC_URL" >> ~/.bash_profile
echo "export FORTA_DIR=~/.forta" >> ~/.bash_profile

# Apply the changes
source ~/.bash_profile

echo "Configuration complete!"

# Updating and upgrading the system
sudo apt-get update && apt-get upgrade -y

# Installing required packages
sudo apt-get install jq ncdu tmux -y
sudo apt-get install ca-certificates curl gnupg lsb-release -y

# Installing Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Installing Forta
sudo curl https://dist.forta.network/pgp.public -o /usr/share/keyrings/forta-keyring.asc -s
echo 'deb [signed-by=/usr/share/keyrings/forta-keyring.asc] https://dist.forta.network/repositories/apt stable main' | sudo tee -a /etc/apt/sources.list.d/forta.list
sudo apt-get update
sudo apt-get install forta -y

# Creating the Forta service
sudo tee /etc/systemd/system/forta.service > /dev/null <<EOF
[Unit]
Description=Forta
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service
StartLimitIntervalSec=500
StartLimitBurst=5
[Service]
Restart=on-failure
RestartSec=15s
Environment="FORTA_DIR=$FORTA_DIR"
Environment="FORTA_PASSPHRASE=$FORTA_PASSPHRASE"
ExecStart=/usr/bin/forta run
[Install]
WantedBy=multi-user.target
EOF



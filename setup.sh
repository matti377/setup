#!/bin/bash

#check for sudo rights
if [ "$EUID" -ne 0 ]; then
  echo "Please run the script with sudo or as root."
  exit 1
fi

#ask for username and password
read -s -p "Enter your password: " current_username
read -p "Enter the new username: " new_username
read -s -p "Enter your password: " password
echo
read -s -p "Confirm your password: " confirm_password
echo

# Compare the entered password and the confirmed password
if [ "$password" = "$confirm_password" ]; then
    echo "Password confirmed."
else
    echo "Passwords do not match. Please try again."
fi


#update and upgrade
sudo apt update && sudo apt upgrade -y
#configure ufw
sudo ufw allow 22
sudo ufw allow 6969
sudo ufw allow OpenSSH
sudo ufw enable

#configure ssh
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/g; s/^#AllowUsers.*/AllowUsers accountName/g; s/^Port.*/Port 6969/g; s/^PermitEmptyPasswords.*/PermitEmptyPasswords no/g' /etc/ssh/sshd_config

sudo service ssh restart

#set up fail2ban
sudo apt install fail2ban -y

#confihure fail2ban
echo -e "[sshd]\nenabled = true\nport = ssh\nlogpath = /var/log/auth.log\nbantime = 1d\nbanaction = iptables-multiport\nmaxretry = 3" | sudo tee /etc/fail2ban/jail.local

#start and enable fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

#add user
sudo adduser --home /home/$newusername $newusername
usermod -aG sudo $newusername
sudo sh -c "echo '$newusername:$password' | chpasswd"

#automate security updates
sudo dpkg-reconfigure --priority=low unattended-upgrades

#clean
sudo apt autoremove -y
sudo apt-get clean -y
sudo rm -r /home/$current_username/setup

#!/bin/bash

# Check for sudo rights
if [ "$EUID" -ne 0 ]; then
  echo "Please run the script with sudo or as root."
  exit 1
fi

# Ask the user if he understood the information
read -p "This script doesn't give you an complete protection, but is an good starting point for securing your server. Have you read and understand this? (y|n): " yn_understand
if [ "$yn_understand" = "y" ]; then

    # Ask to create a new User
    read -p "Do you want to create a new user? (y|n): " yn_username
    echo


    if [ "$yn_username" = "y" ]; then
        read -p "Enter the new username: " new_username
        echo
        read -s -p "Enter your password: " password
        echo
        read -s -p "Confirm your password: " confirm_password
        echo
        # Compare the entered password and the confirmed password
        if [ "$password" = "$confirm_password" ]; then
            echo "Password confirmed."
        else
            echo "Passwords do not match. Please try again."
            exit 1
        fi
        # Add user
        sudo adduser --home /home/$new_username $new_username
        usermod -aG sudo $new_username
        echo "$new_username:$password" | sudo chpasswd
    else
        # Ask for SSH port
        read -p "Which port do you want to use for SSH: " ssh_port
        echo

        # Update and upgrade
        sudo apt update && sudo apt upgrade -y

        # Configure ufw
        sudo ufw allow $ssh_port
        sudo ufw allow OpenSSH
        sudo ufw enable

        # Configure ssh
        sudo sed -i "s/^PermitRootLogin.*/PermitRootLogin no/g; s/^#AllowUsers.*/AllowUsers $USER/g; s/^Port.*/Port $ssh_port/g; s/^PermitEmptyPasswords.*/PermitEmptyPasswords no/g" /etc/ssh/sshd_config

        # Restart ssh
        sudo service ssh restart

        # Set up fail2ban
        sudo apt install fail2ban -y

        # Configure fail2ban
        echo -e "[sshd]\nenabled = true\nport = $ssh_port\nlogpath = /var/log/auth.log\nbantime = 1d\nbanaction = iptables-multiport\nmaxretry = 3" | sudo tee /etc/fail2ban/jail.local

        # Start and enable fail2ban
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban

        # Automate security updates
        sudo dpkg-reconfigure --priority=low unattended-upgrades

        # Get the IP address using hostname command
        ip_address=$(hostname -I)

        echo "IP Address: $ip_address"

        # Clean
        sudo apt autoremove -y
        sudo apt-get clean -y
    fi
    #final explanation
    echo "The setup is finished, you can now connect to this server using SSH with \n 'ssh $USER@$ip_adress' \n \n"

    #ask to install custom software
    read -p "Do you want to install popular selfhosted software? (y|n): " yn_software
    #
    #
    # !!!!!! change next codeline to "" if [ "$yn_software" = "y" ]; then "" to enable software installation
    #
    #
    #
    if [ "$yn_software" = "yn" ]; then
    #ask for tailscale
    read -p "Do you want to install tailscale (VPN for remote access)? (y|n): " yn_tailscale
    #install tailscale
    if [ "$yn_tailscale" = "y" ]; then
    #ask for plex
    read -p "Do you want to install Plex? (y|n): " yn_plex
    #install tailscale
    if [ "$yn_plex" = "y" ]; then
    #ask for nextcloud
    read -p "Do you want to install Plex? (y|n): " yn_nextcloud
    #install tailscalnextcloude
    if [ "$yn_nextcloud" = "y" ]; then


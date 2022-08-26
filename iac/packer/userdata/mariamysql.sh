#!/bin/bash
DATABASE_PASS='admin123'
sudo yum update -y > /tmp/user-data.log
sudo yum install epel-release -y >>  /tmp/user-data.log
sudo yum install git zip unzip -y >>  /tmp/user-data.log
sudo yum install mariadb-server -y >>  /tmp/user-data.log


# starting & enabling mariadb-server
sudo systemctl start mariadb >>  /tmp/user-data.log
sudo systemctl enable mariadb >>  /tmp/user-data.log
cd /tmp/ >>  /tmp/user-data.log
git clone -b main https://github.com/ashwinbittu/stackApp.git >>  /tmp/user-data.log
#restore the dump file for the application
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/stackApp/src/main/resources/db_backup.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Restart mariadb-server
sudo systemctl restart mariadb >>  /tmp/user-data.log


#starting the firewall and allowing the mariadb to access from port no. 3306
#sudo systemctl start firewalld >>  /tmp/user-data.log
#sudo systemctl enable firewalld >>  /tmp/user-data.log
#sudo firewall-cmd --get-active-zones >>  /tmp/user-data.log
#sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent >>  /tmp/user-data.log
#sudo firewall-cmd --reload >>  /tmp/user-data.log
sudo systemctl restart mariadb >>  /tmp/user-data.log

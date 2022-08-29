export DEBIAN_FRONTEND="noninteractive"
echo set debconf to Noninteractive
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

sudo apt update -y  > /tmp/user-data.log
sudo apt install default-jre -y >>  /tmp/user-data.log
sudo apt install default-jdk -y >> /tmp/user-data.log
sudo apt install tomcat9 tomcat9-admin tomcat9-docs tomcat9-common git -y >> /tmp/user-data.log

sudo systemctl stop tomcat9 >> /tmp/user-data.log
sudo rm -rf /var/lib/tomcat9/webapps/ROOT
cd /var/lib/tomcat9/webapps >> /tmp/user-data.log
sudo curl -O -L -H "X-JFrog-Art-Api:AKCp8nFvgcLcbRxa51de8NQddCdvj3gN4BRkpsPLDRh4qimV1BfmwmdQpXe1HUh88QybFjkGg" "https://ashwinbittu.jfrog.io/artifactory/stackapp-repo/155/stackapp-v2.war" 
sudo mv stackapp-v2.war ROOT.war >> /tmp/user-data.log
sudo systemctl start tomcat9 >> /tmp/user-data.log
systemctl status tomcat9 >> /tmp/user-data.log

touch /home/ubuntu/user-data.log
cat /tmp/user-data.log > /home/ubuntu/user-data.log


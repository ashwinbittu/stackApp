export DEBIAN_FRONTEND="noninteractive"
echo set debconf to Noninteractive
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

sudo apt update -y  > /tmp/user-data.log
sudo apt install curl telnet unzip software-properties-common apt-transport-https lsb-release -y >>  /tmp/user-data.log
curl -fsSL https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/erlang.gpg
sudo apt update -y  >>  /tmp/user-data.log
sudo apt install erlang -y  >>  /tmp/user-data.log
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.deb.sh | sudo bash
sudo apt update -y  >>  /tmp/user-data.log
sudo apt install rabbitmq-server -y >>  /tmp/user-data.log
systemctl status rabbitmq-server.service >>  /tmp/user-data.log
systemctl is-enabled rabbitmq-server.service  >>  /tmp/user-data.log
sudo rabbitmq-plugins enable rabbitmq_management >>  /tmp/user-data.log
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config' >>  /tmp/user-data.log
sudo rabbitmqctl add_user test test >>  /tmp/user-data.log
sudo rabbitmqctl set_user_tags test administrator >>  /tmp/user-data.log
sudo systemctl restart rabbitmq-server >>  /tmp/user-data.log

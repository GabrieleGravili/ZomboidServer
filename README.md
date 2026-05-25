This repository is a collection of scripts from my AWS EC2 Project Zomboid dedicated host. I'm using an ubuntu server os,
so most script are going to be bash scripts.
Before cloning, run these comands as sudo user, be aware of <arguments>
sudo apt update && sudo apt upgrade -y
sudo add-apt-repository multiverse; sudo dpkg --add-architecture i386; sudo apt update
sudo apt install steamcmd
sudo useradd <USER_NAME>
sudo mkdir /opt/pzserver
sudo chown <USER_NAME>:<USER_NAME> /opt/pzserver

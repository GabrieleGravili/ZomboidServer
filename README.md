This repository is to store my scripts from my AWS EC2, Ubuntu server, I use to play with my friends.
Some of the scripts are ment to be runned with AWS Lambdas or S3 Buckets and other things, I guess I'll put a descriptor file inside each Library.
If you wish to use it in any ubuntu server, you must run this script if you're on a brand new VM.
```Bash
#!/bin/bash
GAME_DIRECTORY="<PATH_YOU_WISH_DOWNLOAD_GAME_FILES>"
SERVER_USR=<SERVER_USER_NAME>

apt-get update -y && apt-get upgrade -y
apt-get install software-properties-common -y

add-apt-repository multiverse -y
dpkg --add-architecture i386
apt-get update -y
apt-get install jq bc tmux -y
#this if to download and agree on SteamCMD
echo steam steam/question select I AGREE | debconf-set-selections
echo steam steam/license note '' | debconf-set-selections
apt-get install steamcmd -y

#I'm making a user to run the server
useradd -m -s /bin/bash $SERVER_USR
mkdir -p "$GAME_DIRECTORY"
chown -R $SERVER_USR:$SERVER_USR "$GAME_DIRECTORY"
ln -s /usr/games/steamcmd /usr/local/bin/steamcmd
SETUP_SCRIPT="/tmp/pz_setup.sh"

cat << 'EOF' > $SETUP_SCRIPT
#!/bin/bash
GAME_DIR="$1"
#Here is because I want to autoscale the ram usage to 3/4 (and 1/4 for OS) if it's lower 12GB
#if it's grater il cut-off 4GB for OS and leave the rest for Zomboid
RAM_MB=$(free -m | awk '/^Mem:/ {print $2}')
RAM_GB=$(echo "scale=0; ($RAM_MB + 1024) / 1024" | bc)
if [ "$RAM_GB" -lt "12" ]; then
	Z_RAM=$(echo "($RAM_MB * 3 / 4) / 1024" | bc)
else
	Z_RAM=$(echo "$RAM_GB-4" | bc)
fi
#this command downloads Zomboid from SteamCMD and autoscale ram usage for Zombod
while [ ! -f "$GAME_DIR/ProjectZomboid64.json" ]; do
steamcmd +force_install_dir "$GAME_DIR" +login anonymous +app_update 380870 -beta unstable validate +quit
sleep 2
done
echo "Zomboid successfully installed"
echo "Autoscaling RAM..."
jq --arg ram "-Xmx${Z_RAM}g" '.vmArgs |= map(if startswith("-Xmx") then $ram else . end)' "$GAME_DIR/ProjectZomboid64.json" > "$GAME_DIR/tmp.json" && mv "$GAME_DIR/tmp.json" "$GAME_DIR/ProjectZomboid64.json"
echo "RAM is $Z_RAM"
EOF

chown $SERVER_USR:$SERVER_USR $SETUP_SCRIPT
chmod 700 $SETUP_SCRIPT
su - $SERVER_USR -c "tmux new -ds SteamCMD \"$SETUP_SCRIPT $GAME_DIRECTORY\""
ln -s $GAME_DIRECTORY/start-server.sh startZomboid

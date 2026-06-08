#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../.env"
GAME_DIR=$SERVER_PATH
#SetRam sets the value of RAM allocated to launch any Zomboid sessions
#DownloadServer is a basic function to download the game files with SteamCMD
SetRam(){
	local RAM_MB=$(free -m | awk '/^Mem:/ {print $2}')
	local RAM_GB=$(echo "scale=0; ($RAM_MB + 768) / 1024" | bc)
	if [ "$RAM_GB" -lt "12" ]; then
		Z_RAM=$(echo "($RAM_MB * 3 / 4) / 1024" | bc)
	else
		Z_RAM=$(echo "$RAM_GB-4" | bc)
	fi
jq --arg ram "-Xmx${Z_RAM}g" '.vmArgs |= map(if startswith("-Xmx") then $ram else . end)' "$GAME_DIR/ProjectZomboid64.json" > "$GAME_DIR/tmp.json" && mv "$GAME_DIR/tmp.json" "$GAME_DIR/ProjectZomboid64.json"
}
UpdateServer(){
	/usr/games/steamcmd <<- EOF
	+@ShutdownOnFailedCommand 1
	+@NoPromptForPassword 1
	+force_install_dir "$GAME_DIR"
	+login anonymous
	+app_update 380870 -beta unstable validate
	+quit
	EOF
	if [ $? -ne 0 ]; then
		echo "ERROR: Update Failed"
		exit 1
	fi
	echo "SYSTEM: Update successful"
}
#ReinstallServer is a basic function to deleate some of the gamefiles to allow to update
#it doesn't delete server db, saves, sandbox settings
WipeUpdateServer(){
	rm -r $GAME_DIR/* && UpdateServer
}

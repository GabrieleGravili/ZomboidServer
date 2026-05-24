#!/bin/bash
. ../.env
#DownloadSteamCMD is a basic function to download SteamCMD automaticly
DownloadSteamCMD(){
	mkdir -p $PZ_PATH/SteamCMD
	curl -sqL "https://steamcdn.akamaihd.net/client/installer/steamcmd_linux.tar.gz"\
	| tar zxvf - -C $PZ_PATH/SteamCMD
}
#DownloadServer is a basic function to download the game files from SteamCMD
DownloadServer(){
	. $PZ_PATH//SteamCMD/steamcmd.sh +force_install_dir $PZ_PATH/Server +login anonymous +app_up    date 380870 -beta unstable validate +quit
}
#ReinstallServer is a basic function to deleate some of the gamefiles to allow to update
#it doesn't delete server db, saves, sandbox settings
ReinstallServer(){
	rm -r $PZ_PATH/Server && DowloadServer
}

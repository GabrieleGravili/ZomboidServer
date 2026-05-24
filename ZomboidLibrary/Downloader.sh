#!/bin/bash
. ../.env
DownloadSteamCMD(){
	mkdir -p $PZ_PATH/SteamCMD
	curl -sqL "https://steamcdn.akamaihd.net/client/installer/steamcmd_linux.tar.gz"\
	| tar zxvf - -C $PZ_PATH/SteamCMD
}
DownloadServer(){
	. $PZ_PATH/SteamCMD/steamcmd.sh +force_install_dir $PZ_PATH/Server +login anonymous +app_up    date 380870 -beta unstable validate +quit
}
ReinstallServer(){
	rm -r $PZ_PATH && DowloadServer
}

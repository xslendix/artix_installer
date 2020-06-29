#!/bin/sh

outputFile=""
frameRate=60


if [ -f /tmp/recordingpid ]; then
	choice="$(printf 'Yes\nNo' | dmenu -i -p "A recording is in progress. Do you want to stop it?")" || exit 1

	case "$choice" in
		Yes)
			recpid="$(cat /tmp/recordingpid)"
			kill -15 "$recpid"
			rm -f /tmp/recordingpid
			sleep 3
			kill -9 "$recpid" ;;
	esac

	exit 
fi

drives="$(lsblk -nrpo "name,type,size,mountpoint" | awk '$4!~/\/boot|\/home$|SWAP/&&length($4)>1{printf "%s/\n~/\n",$4,$3}' | sed '/^\s*$/d')" || exit 1
outputFile="$(date +$HOME/Videos/recording-%Y-%m-%d-%H-%M-%S.mkv | xargs -0 printf "%s$drives" | dmenu -p "Enter file path:")" || exit 1

frameRate="$(printf '30\n35\n60' | dmenu -i -p 'Enter framerate:')" || exit 1

choice="$(printf "Yes\nNo" | dmenu -i -p "Are you sure you want to begin recording?")"

case "$choice" in
	Yes)
		ffmpeg -y \
		-f x11grab \
		-framerate $frameRate \
		-video_size "$(xdpyinfo | grep dimensions | awk '{print $2;}')" \
		-i "$DISPLAY" \
		-f alsa -ac 2 -i default \
		"$outputFile" &
		echo $! > /tmp/recordingpid
		notify-send "Started recording!" "File: $outputFile\nPID: $!"
		;;
	No) exit 1 ;;
esac


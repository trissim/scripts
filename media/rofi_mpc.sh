#!/bin/sh

radio_path="$RADIO"
saved_tracks="$RADIO_SAVE"

lower_case(){
	echo "$1" | tr '[:upper:]' '[:lower:]'
}

list_radio(){ 
	choice="$(grep '^#' $radio_path | sed 's/^#//')"
	echo "$choice"
}

mpd_status(){

	status=$(mpc status | sed -n '2 p' | cut -d "[" -f2 | cut -d "]" -f1)
	[ -z "$status" ] && echo ""
	[ ! -z "$status" ] && echo "$status"
}

save_current_track(){
	station=$(cat /tmp/radio)
	track=$(mpc -f %title% current)
	echo "$track" >> "$saved_tracks$station"
}

radio_banner(){
	[ -z "$1" ] && size=30
	[ -z "$2" ] && step=3
	[ -z "$3" ] && separator="   ░▒▓█▓▒░   "
	current=$(mpc status | head -n 1)
	status=$(mpc status | sed -n '2 p' | cut -d "[" -f2 | cut -d "]" -f1)
	station=$(cat /tmp/radio)": "
	[ "$(mpd_status)" = "paused" ] && echo "$station""(Paused)" && exit
	[ -z "$(mpd_status)" ] && echo "Not Playing" && exit
	track=$(mpc -f %title% current)
	[ -z "$track" ] && track="$current" 

	echo $station"$($SCRIPTS/marquee.py $size $step "$separator" "$track")"
}

add_radio(){
	stream_url="$(youtube-dl -g $1)"
	if [ -z $stream_url ] ; then
		stream_url=$1
	fi
	stream_name="$2"
	case "$(cat $radio_path)" in
	    *_"$stream_url"_*) 
		    :
		    ;;
	    *)              
		    if [ ! -z $stream_url ] && [ ! -z $stream_name ]
			then 
			    echo "#$stream_name\n$stream_url" >> $radio_path
		    	fi
			;;
	esac
}

add_radio_menu(){
	url=$(echo "" | dmenu -p "Insert stream URL")
	name=$(echo "" | dmenu -p "Choose stream name")
	add_radio $url $name
}

play_radio(){
	url="$(grep -FxA 1 "#$1" $radio_path | tail -1)"
	if [ ! -z "$url" ]; then
		echo "$1" >| /tmp/radio
		mpc clear
		mpc add "$url"
		mpc play 1
	fi
}

play_radio_menu(){
	radios=$(list_radio)
	nlines=$(echo "$radios" | wc -l)
	choice=$( echo "$radios" | rofi -dmenu -i -l $nlines -p "Select Radio")
	radio play $choice
}


radio(){
	if [ "-m" = "$1" ] || [ "--menu" = "$1" ]
	then 
		choices="Play\nSave Current Track\nAdd"
		menu_item=$(lower_case "$(echo "$choices" | rofi -dmenu -i -l 3 -p "Radio Menu")")
		case "$menu_item" in 
			"add")
				add_radio_menu 
				;;
			"play")
				play_radio_menu 
				;;
			"save current track")
				save_current_track
				
		esac
		
	else
		case $1 in 
			"add")
				shift 
				add_radio $1 $2
				;;
			"play")
				shift
				play_radio $1
				;;
			"list")
				list_radio
				;;
			"banner")
				radio_banner
				;;
				
		esac
	fi
}

#Check if played or pause and show approriate option
[ "$(mpd_status)" = "playing" ] && play_pause="Pause"
[ "$(mpd_status)" = "paused" ] && play_pause="Play"
[ -z "$(mpc current)" ] && play_pause="Play"

is_muted=$(pacmd list-sinks|grep -A 15 '* index'|awk '/muted:/{ print $2 }')
[ "$is_muted" = yes ] && mute_toggle="UnMute"
[ "$is_muted" = no ] && mute_toggle="Mute"

main_menu="Radio\n$play_pause\n$mute_toggle\nNext\nPrev\nRandom"

choice=$1
menu=0

if [ "-m" = "$choice" ] || [ "--menu" = "$choice" ]
then
	nlines=$(echo "$main_menu" | wc -l)
	choice=$(echo "$main_menu" | rofi -dmenu -i -l $nlines -p "MPC Menu")
	menu=1
fi

choice=$(lower_case $choice)
case $choice in
	"play"|"pause")
		mpc toggle
		;;
	"mute"|"unmute")
		pactl set-sink-mute @DEFAULT_SINK@ toggle
		;;
	"next")
		mpc next
		;;
	"prev")
		mpc prev
		;;
	"random")
		mpc random
		;;
	"radio")
		shift
		[ $menu -eq 1 ] && radio "-m"
		[ $menu -eq 0 ] && radio $@
		;;
esac

#!/bin/sh
case "$1" in 
	"")	
		ws_name="$(xdotool getwindowname $(xdotool getactivewindow))"
		;;
	"-m"|"--menu")
		ws_name="$(echo "" | rofi -location 2 -dmenu -l 0 -p "Workspace Name")"
		;;
	default)
		ws_name="$1"
		;;
esac

curr_wm="$(wmctrl -m | sed -n 1p | cut -d" " -f2)"
case "$curr_wm" in
	"i3" ) 
	        echo "$ws_name"
		[ ! -z "$ws_name" ] && i3-msg "rename workspace to \"$ws_name\""
	;;
esac


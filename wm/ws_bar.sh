#!/bin/sh
desktops="$(wmctrl -d)"
ws_list="$(echo "$desktops" | tr -s " " | cut -d" " -f9)"
mon_list="$(echo "$desktops" | tr -s " " | cut -d" " -f6)"
activity_list="$(echo "$desktops" | tr -s " " | cut -d" " -f2)"

active_win=1

while [ $active_win -le $(echo "$ws_list" | wc -l) ]
do
	[ "$(echo "$activity_list" | sed -n "$active_win"p )" = "*" ] && break
	#echo "$(echo "$activity_list" | sed -n "$active_win"p )"
	active_win=$((active_win+1))
done
active_win=$(($active_win-1))
echo $active_win
	



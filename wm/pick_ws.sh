#!/bin/sh
#list_ws=$(i3-msg -t get_workspaces | tr ',' '\n' | grep "name" | cut -d '"' -f 4)
list_ws=$(wmctrl -d | tr -s " " | cut -d" " -f9)
eol=$'\n'
nlines=$(echo "$list_ws" | wc -l )
ws=$(echo "$list_ws" | rofi -dmenu -location 2 -p "Select Workspace" -l "$nlines")
i=1
while [ $i -le $(($nlines)) ]
do
	[ "$(echo "$list_ws" | sed -n "$i"p)" = "$ws" ] && wmctrl -s $(($i-1)) && exit
	i=$(($i+1))
done

new_ws(){
	curr_wm="$(wmctrl -m | sed -n 1p | cut -d" " -f2)"
	case "$curr_wm" in
		"i3" ) 
			[ -z "$!" ] && i3-msg workspace \"$1\"
		;;
	esac
}

[ $i = $(($nlines+1)) ] && new_ws $ws




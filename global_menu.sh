#!/bin/sh


utils(){
	choice="$(echo 'l:[l]auncher\nb:[b]luetooth\nn:[n]otes\nr:[r]ecord\np:[p]yWall\nm:[m]pc' | dmenu -k -p "Util" -h 31)"
	echo "$choice"
	case $choice in
		"")
			:
			;;
		"l")
			dmenu_run
			;;
		"n")
			$HOME/scripts/notes.sh
			;;	
		"b")
			$HOME/scripts/rofi_bluetooth.sh
			;;
		"p")
			$HOME/scripts/pywal/pwm.py -m
			;;
		"m")
			$HOME/scripts/media/rofi_mpc.sh -m
			;;
		"r")		
			$HOME/scripts/media/record.sh -m
			;;
	esac
}

windows(){
	choice="$(echo ' :[space] Select |\ns:[s]end |\nGg:[g]aps |\nrR:[r]ename |\nu:[u]tils' | dmenu -k -p "Windows" -h 31)"
	case $choice in 
		' ') 
			$HOME/scripts/wm/pick_ws.sh
			;;
		's')
			$HOME/scripts/wm/send_ws.sh
			;;
		'g')
			$HOME/scripts/wm/gaps.sh
			;;
		'G')
			$HOME/scripts/wm/gaps.sh -m
			;;
		'r')
			$HOME/scripts/wm/rename_ws.sh 
			;;
		'R')
			$HOME/scripts/wm/rename_ws.sh -m
			;;
		'u')	
			utils
			;;
	esac
}

case $1 in
	'-w')
		windows
		;;
	'-u')
		utils
		;;
esac


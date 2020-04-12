curr_wm="$(wmctrl -m | sed -n 1p | cut -d" " -f2)"
#case "$curr_wm" in
#	"i3" ) 
#	        echo "$ws_name"
#		[ ! -z "$ws_name" ] && i3-msg "rename workspace to \"$ws_name\""
#	;;
#esac
default=4
change=1
CHANGE=5


menu(){
	opts="g:[g]aps |\nKk:[k] more |\njJ:[j] less |\nrR:[r]reset"
	opt="$(echo "$opts" | dmenu -k -h 32)"
	[ "$opt" = "k" ] && inc	 
	[ "$opt" = "K" ] && INC	
	[ "$opt" = "j" ] && dec		
	[ "$opt" = "J" ] && DEC		
	#[ "$opt" = "r" ] && reset
	[ "$opt" = "g" ] && toggle
	[ -z "$opt" ] && exit
	menu
}
toggle() {
	case "$curr_wm" in
		"i3" ) 
			if [ `i3-msg -t get_tree | grep -Po \
    		'.*\\"gaps\\":{\\"inner\\":\K(-|)[0-9]+(?=.*\\"focused\\":true)'` -eq 0 ]; then \
      		  i3-msg gaps inner current set 0; \
    		else \
      		  i3-msg gaps inner current set $default; \
    		fi		
		;;
	esac
}

dec(){
	case "$curr_wm" in
		"i3" ) 
			i3-msg gaps inner current minus $(($change)) 
		;;
	esac
}

DEC(){
	case "$curr_wm" in
		"i3" ) 
			i3-msg gaps inner current minus $(($CHANGE)) 
		;;
	esac
}
inc(){
	case "$curr_wm" in
		"i3" ) 
			i3-msg gaps inner current plus $(($change)) 
		;;
	esac
}

INC(){
	case "$curr_wm" in
		"i3" ) 
			i3-msg gaps inner current plus $(($CHANGE)) 
		;;
	esac
}

#toggle 
case $1 in
	"-m"|"--menu")
		menu
		;;
	*)
		toggle
		;;
esac

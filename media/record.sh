#!/bin/sh
path=""
name="cast_`date '+%Y-%m-%d_%H-%M-%S'`.mp4"

upload(){
	fname="$(basename $1)"
	curl -i -F name="$fname" -F file=@$1 https://uguu.se/api.php?d=upload-tool
}

record(){
	#### get current monitor res and viewport ####
	num_ws=$(wmctrl -d | wc -l)
	res_list="$(xrandr | grep \* | cut -d' ' -f4)"
	active_ws=1
	while [ $active_ws -le $num_ws ] 
	do 
		viewport=$(wmctrl -d | sed -n "$active_ws"p | cut -d' ' -f3)
		[ "$viewport" = "*" ] && break
		active_ws=$(($active_ws+1))
	done
	offset=$(wmctrl -d | sed -n "$active_ws"p | cut -d' ' -f8)
	
	monitor=1
	monitors="$(xrandr | grep ' connected')"
	while [ $monitor -le $(echo "$monitors" | wc -l) ]
	do
		vp="+"$(echo $offset | sed s/,/+/g)
		mon="$(echo "$monitors" | sed -n "$monitor"p)"
		[ ! -z "$(echo "$mon" | grep $vp)" ] && res=$(echo "$res_list" | sed -n "$monitor"p) && break
		monitor=$(($monitor+1))
	done
	
	#### get internal audio device for recording ####
	sources="$(pacmd list-sources|awk '/index:/ {print $0}; /name:/ {print $0}; /device\.description/ {print $0}' | grep monitor | grep alsa)"
	internal="$(echo "$sources" | cut -d'<' -f2 | cut -d'>' -f1)"
	
	rate=10
	[ -z "$path"] && path="/tmp/$name"
	
	
	ffmpeg -y -video_size $res \
	-framerate $rate -f x11grab -i :0.0 \
	-f pulse -i $internal \
	-pix_fmt yuv420p \
	$path \
	&> "$(echo $path | rev | cut -d"." -f2- | rev)".log
}


menu(){
	opts="Record\nStop\nName\nPath\nRate"
	choice="$(echo "$opts" | dmenu -p "Screencast")"
	case $choice in 
		"Record")
		record
		;;
		"Stop")
		pkill ffmpeg
		;;
		"Name")
		name="$(echo "" | dmenu -p "Filename")"
		menu ""
		;;
		"Path")
		path="$(echo "" | dmenu -p "File Path")"
		menu ""
		;;
		"Rate")
		rate="$(echo "" | dmenu -p "Rate")"
		menu ""
		;;
	esac
}

while [ ! -z "$1" ]
do
	case $1 in 
		"-n"|"--name")
			[ ! -z "$2" ] && name="$2"
		;;
		"-p"|"--path")
			[ ! -z "$2" ] && path="$2"
		;;
		"-r"|"--rate")
			[ ! -z "$2" ] && rate="$2"
		;;			
		"-m"|"--menu")
			menu
			exit
		;;
		"-u"|"--upload")
			upload $2
		;;
	esac
	shift
done




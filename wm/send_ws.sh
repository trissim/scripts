wid="$(xdotool getactivewindow)"
$HOME/scripts/wm/pick_ws.sh
curr_ws="$(xdotool get_desktop)"
xdotool set_desktop_for_window $wid $curr_ws

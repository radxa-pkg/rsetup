# shellcheck shell=bash

# shellcheck disable=SC2120
color_channel_picker() {
    local channel="$1" intensity
    if ! intensity=$(inputbox "Please enter the intensity of the $channel channel:" "")
    then
        return 1
    elif ! (( 10#$intensity == 10#$intensity )) || (( 10#$intensity < 0 )) || (( 10#$intensity > 255))
    then
        msgbox "$channel channel value must be between 0 and 255. User entered '$intensity'."
        return 1
    fi
    echo "$intensity"
}

color_picker() {
    local r g b
    if ! r=$(color_channel_picker "RED") || ! g=$(color_channel_picker "GREEN") || ! b=$(color_channel_picker "BLUE")
    then
        return 1
    fi
    cat << EOF
$r
$g
$b
EOF
}

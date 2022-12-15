# shellcheck shell=bash

__hardware_gstreamer_test() {
    local temp
    temp="$(mktemp tmp.XXXXXXXXXX.jpg)"

    if gst-launch-1.0 v4l2src "device=/dev/$RSETUP_MENU_SELECTED" io-mode=4 ! \
                      videoconvert ! \
                      video/x-raw,format=UYVY,width=1920,height=1080 ! \
                      jpegenc ! \
                      multifilesink "location=$temp"
    then
        msgbox "Test image is saved at $temp."
    else
        rm -f "$temp"
        msgbox "Unable to capture an image with $RSETUP_MENU_SELECTED device.
Please check if you have the required libraries installed."
    fi
}

__hardware_video() {
    menu_init
    for i in /dev/video*
    do
        menu_add __hardware_gstreamer_test "$(basename "$i")"
    done
    menu_emptymsg "No supported devices is detected.

Please make sure they are enabled first."
    menu_show "Take a test image with the selected video capture device:"
}

__hardware_gpio_leds() {
    checklist_init

    for i in /sys/bus/platform/drivers/leds-gpio/leds/leds/*
    do
        if [[ -f "$i/trigger" ]]
        then
            checklist_add "$(basename "$i") [$(sed -E "s/.*\[(.*)\].*/\1/" "$i/trigger")]" "OFF"
        fi
    done
    checklist_emptymsg "No supported devices is detected.

Please make sure they are enabled first."
    if ! checklist_show "Below are the available LEDs and their triggers.
Select any to update their trigger." || (( ${#RSETUP_CHECKLIST_STATE_NEW[@]} == 0 ))
    then
        return
    fi

    local triggers
    read -r -a triggers <<< "$(sed "s/\[//;s/\]//" "$(find -L /sys/bus/platform/drivers/leds-gpio/leds/leds/ -mindepth 2 -maxdepth 2 -name 'trigger' 2> /dev/null | head -1)")"

    radiolist_init
    for i in "${triggers[@]}"
    do
        radiolist_add "$i" "OFF"
    done
    if radiolist_show "Please select the new trigger:" && (( ${#RSETUP_RADIOLIST_STATE_NEW[@]} > 0 ))
    then
        for i in "${RSETUP_CHECKLIST_STATE_NEW[@]}"
        do
            read -r -a i <<< "$(checklist_getitem "$i")"
            radiolist_getitem "${RSETUP_RADIOLIST_STATE_NEW[0]}" > "/sys/bus/platform/drivers/leds-gpio/leds/leds/${i[0]}/trigger"
        done
    fi
}

__hardware_rgb_leds() {
    :
}

__hardware() {
    menu_init
    menu_add __hardware_video "Video capture devices"
    menu_add __hardware_gpio_leds "GPIO LEDs"
    menu_add __hardware_rgb_leds "RGB LEDs"
    menu_show "Manage on-board hardware"
}
# shellcheck shell=bash

__hardware_camera() {
    :
}

__hardware_leds() {
    checklist_init
    for i in /sys/class/leds/*
    do
        checklist_add "$(basename "$i") [$(sed -E "s/.*\[(.*)\].*/\1/" "$i/trigger")]" "OFF"
    done
    if ! checklist_show "Below are the available LEDs and their triggers.\nSelect any to update their trigger." || (( ${#RSETUP_CHECKLIST_STATE_NEW[@]} == 0 ))
    then
        return
    fi

    local triggers
    read -r -a triggers <<< "$(sed "s/\[//;s/\]//" "$i/trigger")"

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
            radiolist_getitem "${RSETUP_RADIOLIST_STATE_NEW[0]}" > "/sys/class/leds/${i[0]}/trigger"
        done
    fi
}

__hardware() {
    menu_init
    menu_add __hardware_camera "Camera"
    if ls /sys/class/leds/*/trigger &> /dev/null
    then
        menu_add __hardware_leds "LEDs"
    fi
    menu_show "Manage on-board hardware"
}
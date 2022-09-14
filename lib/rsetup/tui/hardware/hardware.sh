#!/bin/bash

__hardware_LED() {
    checklist_init
    for leditem in /sys/class/leds/*
    do  
        local tmp_trigger=$(sed -E "s/.*\[(.*)\].*/\1/" /sys/class/leds/$leditem/trigger)
        checklist_add "$leditem [$tmp_trigger]" "OFF"
    done 

    if ! checklist_show "LEDs with current trigger"  
    then
        return
    fi

    # collect chosen leds
    local chosen_leds
    for shrinked_index in ${RSETUP_CHECKLIST_STATE_NEW[@]}
    do
        local trimmed_index=${shrinked_index//\"}
        local index=$(( trimmed_index * 3 + 1))
        chosen_leds+=(${RSETUP_CHECKLIST[$index]% *})
    done

    for trigger in $(sed "s/\[//;s/\]//" /sys/class/leds/$leditem/trigger)
    do
        radiolist_add "$trigger" "OFF"
    done

    if radiolist_show "Change triggers"  && (( ${#RSETUP_RADIOLIST_STATE_NEW[@]} > 0 ))
    then
        local only_shrinked_index=${RSETUP_RADIOLIST_STATE_NEW}
        trimmed_index=${only_shrinked_index//\"}
        index=$(( trimmed_index * 3 + 1))
        local trigger_to_apply=${RSETUP_RADIOLIST[$index]}
    fi

    for leditem in "${chosen_leds[@]}"
    do
        echo $trigger_to_apply > "/sys/class/leds/$leditem/trigger"
    done
}

__hardware() {
    menu_init
    if ls /sys/class/leds/*/trigger &> /dev/null
    then
        menu_add __hardware_LED "LED"
    else
        menu_add __tui_about "about"
    fi
    menu_show "Customize On-board Functions"
}
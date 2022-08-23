__hardware_LED() {
    local LEDs_names=$(ls /sys/class/leds)
    local root_of_leds="/sys/class/leds"
    local index
    local trimmed_index
    local trigger_to_apply
    chosen_leds=()

    checklist_init
    for item in $LEDs_names
    do  
        tmp_trigger=$(sed -E "s/.*\[(.*)\].*/\1/" /sys/class/leds/$item/trigger)
        checklist_add "$item[$tmp_trigger]" "OFF"
    done
    checklist_show "LEDs with current trigger"     

    if [[ $? != 0 ]]
    then
        return
    fi

    # collect chosen leds
    for shrinked_index in ${RSETUP_CHECKLIST_STATE_NEW[@]}
    do
        trimmed_index=${shrinked_index//\"}
        index=$(($trimmed_index*3+1))
        chosen_leds+=(${RSETUP_CHECKLIST[$index]})
    done

    for trigger in $(sed "s/\[//;s/\]//" /sys/class/leds/$item/trigger)
    do
        radiolist_add "$trigger" "OFF"
    done
    radiolist_show "Change triggers"

    if [[ $? == 0 ]] && [[ ${#RSETUP_RADIOLIST_STATE_NEW[@]} -gt 0 ]]
    then
        only_shrinked_index=${RSETUP_RADIOLIST_STATE_NEW}
        only_trimmed_index=${only_shrinked_index//\"}
        only_index=$((3*$only_trimmed_index+1))
        trigger_to_apply=${RSETUP_RADIOLIST[$only_index]}
    fi

    for led in ${chosen_leds[@]}
    do
        echo $trigger_to_apply > $root_of_leds/$(echo $led | sed "s/\s*\[.*//g")/trigger
    done
}

__hardware() {
    menu_init
    ls /sys/class/leds > /dev/null 2>&1
    if(( $? == 0 ))
    then
        menu_add __hardware_LED "LED"
    fi
    menu_show "Customize On-board Functions"
}
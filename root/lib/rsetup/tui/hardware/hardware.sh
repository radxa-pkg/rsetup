__hardware_LED() {
    local LEDs_names=$(ls /sys/devices/platform/$(ls "/sys/devices/platform/" |grep leds)/leds/)
    local root_of_leds="/sys/devices/platform/$(ls "/sys/devices/platform/" |grep leds)/leds/"
    checklist_init
    for item in $LEDs_names
    do  
        read line < $root_of_leds/$item/trigger
        tmp_trigger=$(echo $line | cut -d "[" -f2 | cut -d "]" -f1)
        if [[ $tmp_trigger == $line ]]
        then
            checklist_add "$item[]" "OFF"
        else
            checklist_add "$item[$tmp_trigger]" "OFF"
        fi
    done
    checklist_show "LEDs with current trigger"
    if [[ $? == 0 ]] && [[ ${#RSETUP_CHECKLIST_STATE_NEW[@]} -gt 0 ]]
    then
        saved_item=()
        local index
        local trimmed_index
        for shrinked_index in ${RSETUP_CHECKLIST_STATE_NEW[@]}
        do
            trimmed_index=${shrinked_index//\"}
            index=$(($trimmed_index*3+1))
            itemselected=${RSETUP_CHECKLIST[index]} 
            saved_item+=(${itemselected})
        done
        __hardware_change_led_trigger
    else
        return
    fi
}

__hardware_change_led_trigger() { 
    local root_of_leds=/sys/devices/platform/$(ls "/sys/devices/platform/" |grep leds)/leds/
    for selected_led in ${saved_item[@]} # scope??
    do 
        radiolist_init
        trimmed_selected_led=$(echo $selected_led |cut -d "[" -f1)   
        read triggers < $root_of_leds/$trimmed_selected_led/trigger
        for trigger in $triggers
        do
            if [[ $trigger == *"["* ]]
            then
            radiolist_add "$trigger" "ON"
            else
            radiolist_add "$trigger" "OFF"
            fi
        done
        radiolist_show "Change $selected_led triggers"
        if [[ $? == 0 ]] && [[ ${#RSETUP_RADIOLIST_STATE_NEW[@]} -gt 0 ]]
        then
            only_shrinked_index=${RSETUP_RADIOLIST_STATE_NEW}\
            only_trimmed_index=${only_shrinked_index//\"}
            only_index=$((3*$only_trimmed_index+1))
            single_item_selected=${RSETUP_RADIOLIST[index]}
            echo $single_item_selected > $root_of_leds/$trimmed_selected_led/trigger
        else
            continue
        fi
    done
}

__hardware() {
    menu_init
    menu_add __hardware_LED "LED"
    menu_show "Customize On-board Functions"
}
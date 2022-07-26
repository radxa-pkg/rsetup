__local_timezone_check(){
    local timezone=$(cat /etc/timezone)
    msgbox "The current time zone: $timezone"
    unregister_screen
}

__local_timezone_change(){
    local timezone=$(cat /etc/timezone)
    local item 
    item=$(yesno "Current time zone: $timezone. Whether or not to change?")
    if [ $? = 0 ]
    then
        local change=$(tzselect)
    fi
    unregister_screen 
}

__local_timezone(){
    menu_init
    menu_add __local_timezone_check      "Check  Timezone"
    menu_add __local_timezone_change     "Change Timezone"
    menu_show "Please select an option below:"
}
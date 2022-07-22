#! /bin/bash


__local_timezone_check(){
    TIMEZONE=$(cat /etc/timezone)
    msgbox "The current time zone: $TIMEZONE"
    unregister_screen
}


__local_timezone_change(){
    TIMEZONE=$(cat /etc/timezone)
    local ITEM
    ITEM=$(yesno "Current time zone: $TIMEZONE. Whether or not to change?")
   
    if [ $? = 0 ]
    then
        CHANGE=$(tzselect)
    fi

    unregister_screen 
}





__local_timezone(){
    menu_init
    menu_add __local_timezone_check      "Check  Timezone"
    menu_add __local_timezone_change     "Change Timezone"
    menu_show "Please select an option below:"
}
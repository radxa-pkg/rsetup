#! /bin/bash

software_advanced_update_firmware() {
  local ITEM
    ITEM=$(yesno "firmware updates Yes, or No?")
   
    if [ $? = 0 ]
    then
        for i in {0..100}
        do
            echo $(( i * 1 ))
            sleep 0.05
        done | gauge "Updating..." 0

        msgbox "Update successful."
    else
        msgbox "User selected no."
    fi

    unregister_screen
}



software_advanced_update_Kernel() {
    local ITEM
    ITEM=$(yesno "Kernel updates Yes, or No?")
    if [ $? = 0 ]
    then

        for i in {0..100}
        do
            echo $(( i * 1 ))
            sleep 0.05
        done | gauge "Please wait for the update." 0

        msgbox "Kernel update completed."
    else  
        msgbox "User selected no."
    fi

    unregister_screen
}
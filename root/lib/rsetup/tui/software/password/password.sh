#! /bin/bash

software_password_change() {
    local ITEM
    ITEM=$(passwordbox "Please enter your old password.")
    if [ $? = 0 ]
    then
        if [ $ITEM = 123456 ]
        then
            ITEM=$(passwordbox "Please enter a new password.")
            if [ $? = 0 ]
            then
                msgbox "Change the password successfully.\nNew password: $ITEM "
            fi
        else
            msgbox "wrong password!"
        fi
    else
        msgbox "User cancelled action."
    fi

    unregister_screen
}



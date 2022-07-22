#! /bin/bash

__local_keyboard_layout(){

    local ITEM
    ITEM=$(yesno "Do you want to modify the keyboard layout?")
   
    if [ $? = 0 ]
    then
        #CHANGE=$(sudo dpkg-reconfigure keyboard-configuration)
        msgbox "modify..."
    fi
    unregister_screen

}
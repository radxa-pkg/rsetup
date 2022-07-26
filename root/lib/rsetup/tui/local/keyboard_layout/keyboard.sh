__local_keyboard_layout(){
    local item=$(yesno "Do you want to modify the keyboard layout?")
    if [ $? = 0 ]
    then
        #local change=$(sudo dpkg-reconfigure keyboard-configuration)
        msgbox "modify..."
    fi
    unregister_screen
}
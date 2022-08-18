source "$ROOT_PATH/lib/rsetup/tui/local/timezone/timezone.sh"

__local_locale() {
    dpkg-reconfigure locales
}

__local_display_language() {
    local lg=$(locale | sed -n '1p' | cut -d '=' -f 2)
    msgbox "Current language used by the system: $lg"     
}

__local_install_CJKV_fonts() {
    local item
    item=$(yesno "Are you sure to install CJKV fonts?")
    if [[ $? == 0 ]]
    then
        apt-get install fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core
        if [[ $? == 0 ]]
        then
            msgbox "Install CJKV fonts success."
        else
            msgbox "Install CJKV fonts failure."    
        fi 
    fi    
}

__local_keyboard_layout() {
    dpkg-reconfigure keyboard-configuration
}

__local_wifi_country() {
    wifi_country_set
    if [[ $? != 0 ]]
    then
        msgbox "There was an error running option WiFi country." 
    fi  
}

__local() {
    menu_init
    menu_add __local_timezone           "Timezone"
    menu_add __local_locale             "Locale"
    menu_add __local_keyboard_layout    "Keyboard Layout"
    menu_add __local_display_language   "Display Language"
    menu_add __local_wifi_country       "WiFi Country"
    menu_add __local_install_CJKV_fonts "Install CJKV Fonts"
    menu_show "Please select an option below:"
}
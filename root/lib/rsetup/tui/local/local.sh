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
        local fonts=( "fonts-arphic-ukai" "fonts-arphic-uming" "fonts-ipafont-mincho" "fonts-ipafont-gothic" "fonts-unfonts-core" )
        for(( i=0; i<${#fonts[@]}; i++ ))
        do  
            apt-get install -y ${fonts[$i]} 2>/dev/null
            if [[ $? != 0 ]]
            then
                echo $(( (i + 1) * 20 )) 
                echo $i > "$(pwd)/tmp_file"
            else
                echo 0 > "$(pwd)/tmp_file"
                exit 1
            fi   
        done | gauge "Installing..." 0
        
        local result=$(cat $(pwd)/tmp_file) 
        if [[ "$result" != "0" ]]
        then
            msgbox "Install CJKV fonts success."
        else
            msgbox "Install CJKV fonts failure."
        fi
        rm $(pwd)/tmp_file
    fi 
}

__local_keyboard_layout() {
    dpkg-reconfigure keyboard-configuration
}

__local_wifi_country() {
    wifi_country_set
    if [[ $? != 0 ]]
    then
        msgbox "Something went wrong when trying to set Wi-Fi country. Please try again." 
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
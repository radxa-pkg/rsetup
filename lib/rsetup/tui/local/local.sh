#!/bin/bash

source "$ROOT_PATH/lib/rsetup/tui/local/timezone/timezone.sh"

__local_locale() {
    dpkg-reconfigure locales
}

__local_display_language() {
    local lg
    lg=$(locale | sed -n '1p' | cut -d '=' -f 2)
    msgbox "Current language used by the system: $lg"
}

__local_install_CJKV_fonts() {
    if yesno "Are you sure to install CJKV fonts?"
    then
        local fonts=( "fonts-arphic-ukai" "fonts-arphic-uming" "fonts-ipafont-mincho" "fonts-ipafont-gothic" "fonts-unfonts-core" )
        for(( i = 0; i < ${#fonts[@]}; i++ ))
        do
            
            if apt-get install -y "${fonts[$i]}" 2>/dev/null
            then
                echo $(( (i + 1) * 20 ))
                echo "$i" > "$(pwd)/tmp_file"
            else
                echo 0 > "$(pwd)/tmp_file"
                exit 1
            fi
        done | gauge "Installing..." 0

        local result
        result=$(cat $(pwd)/tmp_file)
        if [[ "$result" != "0" ]]
        then
            msgbox "CJKV fonts installed successfully."
        else
            msgbox "Failed to install CJKV fonts."
        fi
        rm $(pwd)/tmp_file
    fi
}

__local_keyboard_layout() {
    dpkg-reconfigure keyboard-configuration
}

__local_wifi_country() {
    if wifi_country_set
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
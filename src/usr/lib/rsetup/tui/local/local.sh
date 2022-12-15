# shellcheck shell=bash

source "/usr/lib/rsetup/tui/local/timezone/timezone.sh"

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
        local tmp fonts=( "fonts-arphic-ukai" "fonts-arphic-uming" "fonts-ipafont-mincho" "fonts-ipafont-gothic" "fonts-unfonts-core" )
        tmp="$(mktemp)"
        for(( i = 0; i < ${#fonts[@]}; i++ ))
        do

            if apt-get install -y "${fonts[$i]}" 2>/dev/null
            then
                echo $(( (i + 1) * 20 ))
                echo "$i" > "$tmp"
            else
                echo 0 > "$tmp"
                exit 1
            fi
        done | gauge "Installing..." 0

        if [[ "$(cat "$tmp")" != "0" ]]
        then
            msgbox "CJKV fonts installed successfully."
        else
            msgbox "Failed to install CJKV fonts."
        fi
        rm -f "$tmp"
    fi
}

__local_keyboard_layout() {
    dpkg-reconfigure keyboard-configuration
}

__local_wifi_country() {
    local iface
    iface=$(iw dev | grep Interface | awk '{print $2}')
    if [[ -z "$iface" ]]
    then
        msgbox "No wireless interface found."
        return 1
    fi

    if ! wpa_cli -i "$iface" status &>/dev/null
    then
        msgbox "Could not communicate with wpa_supplicant."
        return 1
    fi

    radiolist_init

    while read -r
    do
        if grep -q "^#.*" <<< "$REPLY"
        then
            continue
        fi
        radiolist_add "$REPLY" "OFF"
    done < /usr/share/zoneinfo/iso3166.tab

    if radiolist_show "Select your Wi-Fi country:" && (( ${#RSETUP_RADIOLIST_STATE_NEW[@]} > 0 ))
    then
        local only_shrinked_index=${RSETUP_RADIOLIST_STATE_NEW}
        trimmed_index=${only_shrinked_index//\"}
        index=$(( 3 * trimmed_index + 1 ))
        local country=${RSETUP_RADIOLIST[$index]}

        if yesno "Are you sure to change Wi-Fi country to: '$country'?"
        then
            country=$(echo "$country" | cut -c 1-2)

            wpa_cli -i "$iface" set country "$country"
            wpa_cli -i "$iface" save_config > /dev/null 2>&1
            iw reg set "$country"

            local file="/etc/default/crda"
            if [[ ! -f $file ]]
            then
                touch $file
            fi

            if grep -q "^REGDOMAIN=" "$file"
            then
                sed -i "/REGDOMAIN=.*/cREGDOMAIN=$country" $file
            else
                sed -i "\$aREGDOMAIN=$country" $file
            fi

            if command -v rfkill &> /dev/null
            then
                rfkill unblock wifi
            fi
            msgbox "Wireless LAN country set to $country."
        fi
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
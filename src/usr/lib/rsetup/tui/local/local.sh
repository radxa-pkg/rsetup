# shellcheck shell=bash

__local_change_timezone() {
    dpkg-reconfigure tzdata
}

__local_change_locale() {
    dpkg-reconfigure locales
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

    if radiolist_show "Select your Wi-Fi country:" && (( ${#RTUI_RADIOLIST_STATE_NEW[@]} > 0 ))
    then
        local only_shrinked_index=${RTUI_RADIOLIST_STATE_NEW}
        trimmed_index=${only_shrinked_index//\"}
        index=$(( 3 * trimmed_index + 1 ))
        local country=${RTUI_RADIOLIST[$index]}

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
    menu_add __local_change_timezone    "Change Timezone"
    menu_add __local_change_locale      "Change Locale"
    if $DEBUG
    then
        menu_add __local_keyboard_layout    "Change Keyboard Layout"
    fi
    menu_add __local_wifi_country       "Change Wi-Fi Country"
    menu_show "Please select an option below:"
}

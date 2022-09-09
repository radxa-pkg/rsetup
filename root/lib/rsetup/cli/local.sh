wifi_country_set() {
    __parameter_count_check 0 "$@"
    local iface=$(iw dev | grep Interface | awk '{print $2}')
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
    local status="OFF"
    local i=0

    while read
    do
        if grep -q "^#.*" <<< $REPLY
        then
            continue
        fi
        radiolist_add "$REPLY" "$status"
        local country[$i]="$REPLY"
        i=$(( i + 1 ))
    done < /usr/share/zoneinfo/iso3166.tab

    if radiolist_show "Select your Wi-Fi country:" && yesno "You selected is ${country[${RSETUP_RADIOLIST_STATE_NEW[*]}]}."
    then
        country="${country[${RSETUP_RADIOLIST_STATE_NEW[*]}]}"
        country=$(echo $country | cut -c 1-2)

        wpa_cli -i "$iface" set country "$country"
        wpa_cli -i "$iface" save_config > /dev/null 2>&1
        iw reg set $country

        local file="/etc/default/crda"
        if [[ ! -f $file ]]
        then
            touch $file
        fi

        local keywords=$(cat $file | grep "^REGDOMAIN=")
        if [[ ! -z $keywords ]]
        then
                sed -i '/REGDOMAIN=.*/cREGDOMAIN='$country'' $file
        else
                sed -i '$aREGDOMAIN='$country'' $file
        fi

        if command -v rfkill &> /dev/null
        then
            rfkill unblock wifi
        fi
        msgbox "Wireless LAN country set to $country."
    fi
}
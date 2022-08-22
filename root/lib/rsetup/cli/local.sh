wifi_country_set() {
    __parameter_count_check 0 "$@"
    local iface=$(iw dev | grep Interface | awk '{print $2}')
    if [[ -z "$iface" ]]
    then
        msgbox "No wireless interface found." 
        return 1
    fi
    if [[ ! `wpa_cli -i "$iface" status > /dev/null 2>&1` ]]
    then
        msgbox "Could not communicate with wpa_supplicant."
        return 1
    fi
    radiolist_init
    local status="OFF"
    local count=$(awk 'END{print NR}' /usr/share/zoneinfo/iso3166.tab)
    count=$((count-25))
    for ((i=1;i<=$count;i++))
    do
        local country[$i-1]=$(cat /usr/share/zoneinfo/iso3166.tab | tail -n +26 | awk 'NR=='$i' {print $0}' | tr '\t' "  ")
        radiolist_add "${country[$i-1]}" "$status"   
    done   
    radiolist_show "Radiolist"
    if [[ $? == 0 ]]
    then
        local item
        item=$(yesno "You selected is ${country[${RSETUP_RADIOLIST_STATE_NEW[*]}]}.")
        if [[ $? == 0 ]]
        then
            country=${country[${RSETUP_RADIOLIST_STATE_NEW[*]}]} 
            country=`echo $country | cut -c 1-2`
            wpa_cli -i "$iface" set country "$country"
            wpa_cli -i "$iface" save_config > /dev/null 2>&1
            iw reg set $country
            local file="/etc/default/crda"
            if [[ ! -f $file ]]
            then
                touch $file   
            fi

            local string="REGDOMAIN=$country"
            local keywords=$(cat $file | grep "REGDOMAIN=")

            if [[ ! -z $keywords ]]
            then
                local row=$(grep -n ^REGDOMAIN $file  | cut -d ":" -f 1)
                sed -i ''$row'd' $file    
            fi
            sed -i '$a'$string'' $file     
            if hash rfkill 2> /dev/null
            then
                rfkill unblock wifi
            fi 
            msgbox "Wireless LAN country set to $country."
        fi
    fi   
}
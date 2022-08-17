__user_change_password (){
    local new_passward, new_passward2
    new_passward=$(passwordbox "Please enter the new password:")
    if [[ $? == 0 ]]
    then
        new_passward2=$(passwordbox "Please enter the new password again:")
        while [[ $? == 0 ]] 
        do
            if [[ "$new_passward" != "$new_passward2" ]]
            then
                msgbox "The passwards are not consistent."
                new_passward2=$(passwordbox "Please enter the new password again:")
            else
                if update_password "$(last | head -1 | cut -d ' ' -f1)" "$new_passward"
                then
                    msgbox "Password has been changed."
                else
                    msgbox "An error has occured when trying to change password." 
                fi
            fi
        done
        return
    else
        return
    fi
}

__user_change_hostname (){
    local cur_name="$(hostname)"
    local item
    item=$(inputbox "Please enter the new hostname:" "$cur_name")
    if [[ $? != 0 ]] || [[ -z "$item" ]] || [[ "$item" == "$cur_name" ]]
    then
        msgbox "Hostname is not changed."
    else
        if update_hostname "$item"
        then
            msgbox "Hostname has been changed to '$item'."
        else
            update_hostname "$cur_name"
            msgbox "An error occured when trying to change hostname.
Hostname has been set to '$(hostname)'."
        fi
    fi
}

__user_enable_auto_login (){
    username="$(last | head -1 | cut -d ' ' -f1)"
    scanned_tty_services=$(ls /etc/systemd/system/getty.target.wants | grep 'tty' |grep -v '.d')
    local selected_tty_device
    local parameter
    checklist_init
    for tty_service in $scanned_tty_services
    do
        checklist_add "$tty_service" "OFF"
    done
    checklist_show "Choose the tty device/devices you prefer"
    if [[ $? == 0 ]] && [[ ${#RSETUP_CHECKLIST_STATE_NEW[@]} -gt 0 ]]
    then
        for selected_tty_shrinked_index in ${RSETUP_CHECKLIST_STATE_NEW[@]}
        do
            selected_tty_real_index=$((3*${selected_tty_shrinked_index//\"}+1))
            selected_tty_device=${RSETUP_RADIOLIST[${selected_tty_real_index}]}
            SYSTEMD_OVERRIDE=/etc/systemd/system/getty.target.wants/$selected_tty_device.d
            msgbox "Setting up auto login..."
            mkdir -p $SYSTEMD_OVERRIDE
            touch $SYSTEMD_OVERRIDE/override.conf
            cat << EOF | tee $SYSTEMD_OVERRIDE/override.conf >/dev/null
[Service]
ExecStart=
EOF
            parameter="$(grep "ExecStart" /etc/systemd/system/getty.target.wants/$selected_tty_device | cut -d ' ' -f2-)"
            AUTOLOGIN=""ExecStart=-/sbin/agetty --autologin $username "$parameter"
            tee -a $SYSTEMD_OVERRIDE/override.conf <<< $AUTOLOGIN >/dev/null
        done
        passwd --delete $username >/dev/null
    else
        return
    fi
}

__user() {
    menu_init
    menu_add __user_change_password "Change Password"
    menu_add __user_change_hostname "Change Hostname"
    menu_add __user_enable_auto_login "Enable Auto Login"
    menu_show "User Settings"
}
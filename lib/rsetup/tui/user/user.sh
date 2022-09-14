# shellcheck shell=bash

__user_change_password (){
    local new_password=1
    local new_password2
    while [[ "$new_password" != "$new_password2" ]]
    do
        if ! new_password=$(passwordbox "Please enter the new password:")
        then
            return
        fi
        
        if ! new_password2=$(passwordbox "Please confirm your password:")
        then
            return
        fi

        if [[ "$new_password" != "$new_password2" ]]
        then
            msgbox "Passwords do not match. Try again"
        fi
    done

    if update_password "$(logname)" "$new_password"
    then
        msgbox "The password has been changed."
    else
        msgbox "An error has occured when trying to change password." 
    fi
}

__user_change_hostname (){
    local cur_name item
    cur_name="$(hostname)"
    if ! item=$(inputbox "Please enter the new hostname:" "$cur_name") || \
       [[ -z "$item" ]] || \
       [[ "$item" == "$cur_name" ]]
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
    local username selected_tty_device parameter
    username="$(logname)"

    checklist_init
    for i in /etc/systemd/system/getty.target.wants/*tty*.service
    do
        checklist_add "$(basename "$i")" "OFF"
    done
    if ! checklist_show "Please select the interface(s) you want to enable auto login:" || (( ${#RSETUP_CHECKLIST_STATE_NEW[@]} == 0))
    then
        return
    fi
    
    if ! yesno "After auto login is enabled, your current password will be deleted, and you can only login SSH with public key.
Are you sure to continue?"
    then 
        return
    fi

    for selected_tty_shrinked_index in "${RSETUP_CHECKLIST_STATE_NEW[@]}"
    do
        selected_tty_real_index=$((3*${selected_tty_shrinked_index//\"}+1))
        selected_tty_device=${RSETUP_RADIOLIST[${selected_tty_real_index}]}
        SYSTEMD_OVERRIDE=/etc/systemd/system/getty.target.wants/$selected_tty_device.d
        mkdir -p "$SYSTEMD_OVERRIDE"
        cat << EOF > "$SYSTEMD_OVERRIDE/override.conf"
[Service]
ExecStart=
EOF
        parameter="$(grep "ExecStart" "/etc/systemd/system/getty.target.wants/$selected_tty_device" | cut -d ' ' -f2-)"
        AUTOLOGIN="ExecStart=-/sbin/agetty --autologin $username $parameter"
        echo "$AUTOLOGIN" >> "$SYSTEMD_OVERRIDE/override.conf"
    done
    if passwd --delete "$username" >/dev/null
    then 
        msgbox "Configuration succeeded"
    fi
}

__user() {
    menu_init
    menu_add __user_change_password "Change Password"
    menu_add __user_change_hostname "Change Hostname"
    menu_add __user_enable_auto_login "Enable Auto Login"
    menu_show "User Settings"
}
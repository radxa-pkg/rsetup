# shellcheck shell=bash

__user_change_password (){
    local new_password=1 new_password2=
    while [[ "$new_password" != "$new_password2" ]]
    do
        if ! new_password=$(passwordbox "Please enter the new password for $(logname):")
        then
            return
        fi

        if ! new_password2=$(passwordbox "Please confirm your password:")
        then
            return
        fi

        if [[ "$new_password" != "$new_password2" ]]
        then
            msgbox "Passwords do not match. Please try again."
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
            msgbox "Hostname has been changed to $item.
Please reboot for the change to take effect."
        else
            update_hostname "$cur_name"
            msgbox "An error occured when trying to change hostname.
Hostname has been set to $(hostname)."
        fi
    fi
}

__user_enable_auto_login (){
    local username service
    username="$(logname)"

    checklist_init
    while read -r; do
        service="$(awk '{print $1}' <<< "$REPLY")"
        checklist_add "$service" "$(get_autologin_status "$service")"
    done < <(systemctl list-units --state running --no-legend -- "*getty@*.service" sddm.service gdm.service lightdm.service)
    if ! checklist_show "Please select the service(s) you want to enable auto login:" || checklist_is_selection_empty
    then
        return
    fi

    while read -r; do
        service="$(awk '{print $1}' <<< "$REPLY")"
        set_autologin_status "$username" "$service" "OFF"
    done < <(systemctl list-units --state running --no-legend -- "*getty@*.service" sddm.service gdm.service lightdm.service)

    for i in "${RTUI_CHECKLIST_STATE_NEW[@]}"
    do
        i="${i//\"}"
        j=$((3 * i + 1))
        service="${RTUI_CHECKLIST[$j]}"
        set_autologin_status "$username" "$service" "ON"
    done

    msgbox "Auto login settings has been updated."
}

__user() {
    menu_init
    menu_add __user_change_password "Change Password"
    menu_add __user_change_hostname "Change Hostname"
    menu_add __user_enable_auto_login "Configure auto login"
    menu_show "User Settings"
}

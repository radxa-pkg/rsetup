__user_change_password (){
    msgbox "Change password."
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
    msgbox "Enable auto login."
}

__user() {
    menu_init
    menu_add __user_change_password "Change Password"
    menu_add __user_change_hostname "Change Hostname"
    menu_add __user_enable_auto_login "Enable Auto Login"
    menu_show "User Settings"
}
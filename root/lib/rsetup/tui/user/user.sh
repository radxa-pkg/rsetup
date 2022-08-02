__user_change_password (){
    msgbox "Change password."
}

__user_change_hostname (){
    msgbox "Change Hostname."
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
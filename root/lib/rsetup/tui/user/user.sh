__user_change_password (){
    menu_init
    menu_add __tui_about "Change Password"
}

__user_change_hostname (){
    menu_init
    menu_add __tui_about "Change Hostname"
}

__user_enable_auto_login (){
    menu_init
    menu_add __tui_about " "
}

__user() {
    menu_init
    menu_add __user_change_password "Change Password"
    menu_add __user_change_hostname "Change Hostname"
    menu_add __user_enable_auto_login "Enable Auto Login"
    menu_show "User Settings"
}
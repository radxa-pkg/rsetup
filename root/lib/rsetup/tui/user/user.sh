__user_changepwd (){
    menu_init
    menu_add __tui_about "Change Password"
}

__user_changehostname (){
    menu_init
    menu_add __tui_about "Change Hostname"
}

__user_enableautologin (){
    menu_init
    menu_add __tui_about " "
}

__user() {
    menu_init
    menu_add __user_changepwd "Change Password"
    menu_add __user_changehostname "Change Hostname"
    menu_add __user_enableautologin "Enable Auto Login"
    menu_show "User Settings"
}
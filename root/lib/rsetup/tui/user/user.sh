__user() {
    menu_init
    menu_add __user_changepwd "Change password"
    menu_add __user_changehostname "Change hostname"
    menu_add __user_enableautologin "Enable auto login"
    menu_show "User Settings"
}

__user_changepwd (){
    menu_init
    menu_add __tui_about "Change password"
}

__user_changehostname (){
    menu_init
    menu_add __tui_about "Change hostname"
}

__user_enableautologin (){
    menu_init
    menu_add __tui_about " "
}
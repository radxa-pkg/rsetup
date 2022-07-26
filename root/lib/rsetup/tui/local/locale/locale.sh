__local_locale_checkSetup(){
    CUR_SET=$(locale)
    msgbox "Current locale Settings: $CUR_SET"   
    unregister_screen
}

__local_locale_checkAll(){
    local all
    all=$(locale -a)
    msgbox "All available locales. $all"   
    unregister_screen
}

__local_locale(){
    menu_init
    menu_add __local_locale_checkSetup   "Current Locale Settings"
    menu_add __local_locale_checkAll     "All Available Locales"
    menu_show "Please select an option below:"
}
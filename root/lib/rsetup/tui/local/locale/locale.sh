#! /bin/bash



__local_locale_checkSetup(){
    CUR_SET=$(locale)
    msgbox "current locale Settings: $CUR_SET"
    
    unregister_screen

}


__local_locale_checkAll(){
    ALL=$(locale -a)
    msgbox "All available locales. $ALL"
    
    unregister_screen

}

__local_locale(){
    menu_init
    menu_add __local_locale_checkSetup   "current locale Settings"
    menu_add __local_locale_checkAll     "All available locales"
    menu_show "Please select an option below:"
}
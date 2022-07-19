#!/bin/bash

source "$ROOT_PATH/lib/rsetup/mod/tui.sh"

source "$ROOT_PATH/lib/rsetup/tui/software/software.sh"
source "$ROOT_PATH/lib/rsetup/tui/hardware/hardware.sh"
source "$ROOT_PATH/lib/rsetup/tui/test/test.sh"

__main_about() {
    msgbox "rsetup\n\nCopyright 2022 Radxa Ltd."
    
    unregister_screen
}

__main() {
    menu_init
    menu_add __main_System "System" 
    menu_add __main_hardware "Hardware"
    
    
    menu_add __main_40-pinheader "40-pin header"
    menu_add __main_Connectivity "Connectivity"
    menu_add __main_User "User" 


    menu_add __main_software "Software"
   
    menu_add __main_test "Test"
    menu_add __main_about "About"
    menu_show "Please select an option below:"
}
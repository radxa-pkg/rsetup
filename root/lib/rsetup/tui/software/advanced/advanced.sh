#! /bin/bash



source "$ROOT_PATH/lib/rsetup/tui/software/advanced/update/update.sh"




software_advanced_overclock() {
    msgbox "1 Overclock Setup."
    unregister_screen
}

software_advanced_resolution() {
    msgbox "1 Resolution Setup."
    unregister_screen
}

software_advanced_update() {
    menu_init
    menu_add software_advanced_update_firmware  "1 firmware updates"
    menu_add software_advanced_update_Kernel    "2 Kernel   updates"    

    menu_show "TUI tests"      
}
#!/bin/bash

source "$ROOT_PATH/lib/rsetup/tui/software/password/password.sh"
source "$ROOT_PATH/lib/rsetup/tui/software/network/network.sh"
source "$ROOT_PATH/lib/rsetup/tui/software/interface/interface.sh"
source "$ROOT_PATH/lib/rsetup/tui/software/advanced/advanced.sh"

__main_software_password() {
    menu_init
    menu_add software_password_change      "1 change Password"
    menu_show "TUI tests"
}

__main_software_network() {
    menu_init
    menu_add software_network_wifi      "1 WIFI"
    menu_add software_network_ip        "2 IP"
    menu_add software_network_ir        "3 IR"
    menu_add software_network_bt        "4 Bluetooth"
    menu_add software_network_clear     "5 CLEAR"
    menu_add software_network_advanced  "6 Advanced"
    menu_show "TUI tests"
}

__main_software_interface() {
    
    menu_init
    menu_add software_interface_peripheral    "1 Peripheral" 
    menu_add software_interface_ssh           "2 SSH" 
    menu_show "TUI tests"
    
  
}


__main_software_boot() {
    msgbox "1 boot information.\n2 Kernel switch"

    unregister_screen
}


__main_software_language() {
    radiolist_init
    radiolist_add "English" "OFF"
    radiolist_add "Chinese" "ON"
    radiolist_show "Radiolist"
    if [ $? = 0 ]
    then
        #msgbox "Offered '${RSETUP_RADIOLIST_STATE_OLD[*]}', selected '${RSETUP_RADIOLIST_STATE_NEW[*]}'."
        if [ ${RSETUP_RADIOLIST_STATE_NEW[*]} = 0 ]; then
            msgbox "Language: English."
        elif [ ${RSETUP_RADIOLIST_STATE_NEW[*]} = 1 ];then
            msgbox "Language: Chinese."
        fi
    #else
        #msgbox "User cancelled action."
    fi
    unregister_screen
}

__main_software_advanced() {  
    menu_init
    menu_add software_advanced_update           "1 Update"
    menu_add software_advanced_overclock        "2 Overclock"
    menu_add software_advanced_resolution       "3 Resolution"
    menu_show "TUI tests"    
}



__main_software() {
    menu_init
    menu_add __main_software_password   "1 Password  Options"
    menu_add __main_software_network    "2 Network   Options"
    menu_add __main_software_interface  "3 Interface Options"
    menu_add __main_software_boot       "4 Boot      Options"
    menu_add __main_software_language   "5 Language  Options"
    menu_add __main_software_advanced   "6 Advanced  Options"
    menu_show "TUI tests"
}
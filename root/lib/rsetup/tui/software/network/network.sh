#! /bin/bash

source "$ROOT_PATH/lib/rsetup/tui/software/network/ip/ip.sh"

software_network_wifi() {
    msgbox "1 Connect to wifi network.\n2 Disconnect and forget all WIFI connections."
    unregister_screen
}

software_network_ip() {
    menu_init
    menu_add software_network_ip_check      "1 Check the IP."
    menu_add software_network_ip_seltct     "2 Select dynamic or edit static IP address."
    menu_add software_network_ip_control    "3 Disable IPv6 for APT and system."
    menu_show "TUI tests"
}

software_network_bt() {
    msgbox "1 Connect the bluetooth.\n2 Disconnect and forget all Bluetooth connections.\n3 install bluetooth support."
    unregister_screen
}


software_network_ir() {
    msgbox "1 install IR support."
    unregister_screen
}

software_network_clear() {
    msgbox "1 Clear possible blocked interfaces."
    unregister_screen
}


software_network_advanced() {
    msgbox "1 Edit network Interface."
    unregister_screen
}




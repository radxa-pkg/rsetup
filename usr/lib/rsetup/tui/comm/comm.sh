# shellcheck shell=bash

__comm_network() {
    nmtui
}

__comm_bluetooth() {
    msgbox "Configure Bluetooth"
}

__comm() {
    menu_init
    menu_add __comm_network "Network"
    menu_add __comm_bluetooth "Bluetooth"
    menu_show "Customize Connectivity"
}
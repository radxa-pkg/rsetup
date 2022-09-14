#!/bin/bash

__comm_wifi() {
    nmtui
}

__comm_bluetooth() {
    msgbox "Configure Bluetooth"
}

__comm() {
    menu_init
    menu_add __comm_wifi "Wi-Fi"
    menu_add __comm_bluetooth "Bluetooth"
    menu_show "Customize Connectivity"
}
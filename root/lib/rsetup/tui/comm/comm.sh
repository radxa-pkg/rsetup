__comm_wifi() {
    echo "hello"
}

__comm_bluetooth() {
    echo "hello"
}

__comm() {
    menu_init
    menu_add __comm_wifi "Wi-Fi"
    menu_add __comm_bluetooth "Bluetooth"
    menu_show "Customize Connectivity"
}
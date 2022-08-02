__hardware_LED() {
    menu_init
    menu_add __hardware_list_leds "List LEDs"
    menu_add __hardware_change_led_trigger "Change LED trigger"
    menu_show "Customize LEDs"
}

__hardware_list_leds() {
    echo "hello"
}

__hardware_change_led_trigger() {
    echo "hello"
}

__hardware() {
    menu_init
    menu_add __hardware_LED "LED"
    menu_show "Customize On-board Functions"
}
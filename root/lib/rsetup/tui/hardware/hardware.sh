__LED() {
    menu_init
    menu_add __listleds "List LEDs"
    menu_add __changeledtrigger "Change LED trigger"
    menu_show "Customize LEDs"
}

__listleds() {
    echo "hello"
}

__changeledtrigger() {
    echo "hello"
}

__hardware() {
    menu_init
    menu_add __LED "LED"
    menu_show "Customize On-board Functions"
}
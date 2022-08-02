__hardware() {
    menu_init
    menu_add __LED "LED"
    menu_show "Customize onboard functions"
}

__LED() {
    menu_init
    menu_add __listleds "list LEDs"
    menu_add __changeledtrigger "change LED trigger"
    menu_show "Customize onboard functions"
}

__listleds() {
    echo "hello"
    
}

__changeledtrigger() {
    echo "hello"
}
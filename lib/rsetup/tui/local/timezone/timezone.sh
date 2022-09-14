__local_timezone_check() {
    local timezone=$(cat /etc/timezone)
    msgbox "The current time zone: $timezone"
}

__local_timezone_change() {
    dpkg-reconfigure tzdata
}

__local_timezone() {
    menu_init
    menu_add __local_timezone_check      "Check  Timezone"
    menu_add __local_timezone_change     "Change Timezone"
    menu_show "Please select an option below:"
}
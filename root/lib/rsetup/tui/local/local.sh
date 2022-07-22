#! /bin/bash

source "$ROOT_PATH/lib/rsetup/tui/local/timezone/timezone.sh"
source "$ROOT_PATH/lib/rsetup/tui/local/locale/locale.sh"
source "$ROOT_PATH/lib/rsetup/tui/local/keyboard_layout/keyboard.sh"
source "$ROOT_PATH/lib/rsetup/tui/local/display_language/language.sh"
source "$ROOT_PATH/lib/rsetup/tui/local/wifi_country/wifi_country.sh"
source "$ROOT_PATH/lib/rsetup/tui/local/install_CJKV_fonts/fonts.sh"

__local() {
    menu_init
    menu_add __local_timezone           "Timezone"
    menu_add __local_locale             "Locale"
    menu_add __local_keyboard_layout    "Keyboard layout"
    menu_add __local_display_language   "Display Language"
    menu_add __local_wifi_country       "WiFi country"
    menu_add __local_install_CJKV_fonts "Install CJKV Fonts"

    menu_show "Please select an option below:"
}

#!/bin/bash

source "$ROOT_PATH/lib/rsetup/mod/dialog/basic.sh"

RSETUP_MENU=()
RSETUP_MENU_CALLBACK=()

menu_init() {
    __parameter_count_check 0 "$@"

    RSETUP_MENU=()
    RSETUP_MENU_CALLBACK=()
}

menu_add() {
    __parameter_count_check 2 "$@"

    local callback=$1
    local item=$2

    RSETUP_MENU+=( "$((${#RSETUP_MENU[@]} / 2))" "$item" )
    RSETUP_MENU_CALLBACK+=( "$callback" )
}

menu_add_separator() {
    menu_add unregister_screen "========="
}

menu_show() {
    __parameter_count_check 1 "$@"

    local item
    item=$(__dialog --menu "$1" "${RSETUP_MENU[@]}" 3>&1 1>&2 2>&3 3>&-)
    if [ $? = 0 ]
    then
        register_screen ${RSETUP_MENU_CALLBACK[$item]}
    else
        if [[ -n $item ]]
        then
            echo "$item"
        fi
        unregister_screen
    fi
}
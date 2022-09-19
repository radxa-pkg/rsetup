# shellcheck shell=bash

# shellcheck disable=SC2120
menu_init() {
    __parameter_count_check 0 "$@"

    export RSETUP_MENU=()
    export RSETUP_MENU_CALLBACK=()
}

menu_add() {
    __parameter_count_check 2 "$@"
    if [[ "$1" != ":" ]]
    then
        __parameter_type_check "$1" "function"
    fi

    local callback=$1
    local item=$2

    RSETUP_MENU+=( "$((${#RSETUP_MENU[@]} / 2))" "$item" )
    RSETUP_MENU_CALLBACK+=( "$callback" )
}

# shellcheck disable=SC2120
menu_add_separator() {
    __parameter_count_check 0 "$@"

    menu_add : "========="
}

menu_emptymsg() {
    __parameter_count_check 1 "$@"

    if (( ${#RSETUP_MENU_CALLBACK[@]} == 0))
    then
        msgbox "$1"
    fi
}

menu_show() {
    __parameter_count_check 1 "$@"

    local item
    if item=$(__dialog --menu "$1" "${RSETUP_MENU[@]}" 3>&1 1>&2 2>&3 3>&-)
    then
        push_screen "${RSETUP_MENU_CALLBACK[$item]}"
    fi
}
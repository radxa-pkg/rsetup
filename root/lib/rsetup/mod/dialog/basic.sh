#!/bin/bash

RSETUP_DIALOG=${RSETUP_DIALOG:-"whiptail"}

__dialog() {
    local box="$1"
    local text="$2"
    shift 2
    local height=12
    local width=80
    case $box in
        --menu|--checklist|--radiolist)
            local listheight=$(( $height - 8 ))
            ;;
        *)
            local listheight=
            ;;
    esac

    $RSETUP_DIALOG --title "RSETUP" --backtitle "${RSETUP_SCREEN[*]}" --notags "$box" "$text" $height $width $listheight "$@"
}

yesno() {
    __parameter_count_check 1 "$@"

    __dialog --yesno "$1" 3>&1 1>&2 2>&3 3>&-
}

msgbox() {
    __parameter_count_check 1 "$@"

    __dialog --msgbox "$1"
}

inputbox() {
    __parameter_count_check 2 "$@"

    __dialog --inputbox "$1" "$2" 3>&1 1>&2 2>&3 3>&-
}

passwordbox() {
    __parameter_count_check 1 "$@"

    __dialog --passwordbox "$1" 3>&1 1>&2 2>&3 3>&-
}

gauge() {
    __parameter_count_check 2 "$@"

    __dialog --gauge "$1" "$2"
}

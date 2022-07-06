#!/bin/bash

RSETUP_DIALOG=${RSETUP_DIALOG:-"whiptail"}

__dialog() {
    local BOX="$1"
    local TEXT="$2"
    shift 2
    local HEIGHT=12
    local WIDTH=80
    case $BOX in
        --menu|--checklist|--radiolist)
            local LISTHEIGHT=$(( $HEIGHT - 8 ))
            ;;
        *)
            local LISTHEIGHT=
            ;;
    esac

    $RSETUP_DIALOG --title "RSETUP" --backtitle "${RSETUP_SCREEN[*]}" --notags "$BOX" "$TEXT" $HEIGHT $WIDTH $LISTHEIGHT "$@"
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

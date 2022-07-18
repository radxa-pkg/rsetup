#!/bin/bash

RSETUP_DIALOG=${RSETUP_DIALOG:-"whiptail"}

__dialog() {
    local box="$1"
    local text="$2"
    shift 2
    local height="$(stty size | cut -d ' ' -f 1)"
    local width="$(stty size | cut -d ' ' -f 2)"
    case $box in
        --menu|--checklist|--radiolist)
            local listheight=0
            ;;
        *)
            local listheight=
            ;;
    esac

    if (( height < 8 ))
    then
        echo "TTY height has to be at least 8 for TUI mode to work, currently $height." >&2
        return 1
    fi

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

#!/bin/bash

RSETUP_DIALOG=${RSETUP_DIALOG:-"whiptail"}

__dialog() {
    local box="$1"
    local text="$2"
    shift 2
    local height="$(__check_terminal | cut -d ' ' -f 1)"
    local width="$(__check_terminal | cut -d ' ' -f 2)"
    case $box in
        --menu)
            local listheight=0
            ;;
        --checklist|--radiolist)
            local listheight=$(( height - 8 ))
            ;;
        *)
            local listheight=
            ;;
    esac

    if (( height < 8 ))
    then
        echo "TTY height needs to be at least 8 for TUI mode to work, currently is '$height'." >&2
        return 1
    fi

    if [[ "$DEBUG" == "1" ]]
    then
        local backtitle=( "--backtitle" "${RSETUP_SCREEN[*]}" )
    else
        local backtitle=()
    fi

    $RSETUP_DIALOG --title "RSETUP" ${backtitle:+"${backtitle[@]}"} --notags "$box" "$text" $height $width $listheight "$@"
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

#!/bin/bash

source "$ROOT_PATH/lib/rsetup/mod/dialog/basic.sh"

radiolist_init() {
    __parameter_count_check 0 "$@"

    RSETUP_RADIOLIST=()
    RSETUP_RADIOLIST_CALLBACK=()
    RSETUP_RADIOLIST_STATE_OLD=()
    RSETUP_RADIOLIST_STATE_NEW=()
}

radiolist_add() {
    __parameter_count_check 2 "$@"

    local ITEM=$1
    local STATUS=$2
    local TAG="$((${#RSETUP_RADIOLIST[@]} / 3))"

    __parameter_value_check "$STATUS" "ON" "OFF"

    RSETUP_RADIOLIST+=( "$TAG" "$ITEM" "$STATUS" )

    if [[ $STATUS == "ON" ]]
    then
        RSETUP_RADIOLIST_STATE_OLD+=( "$TAG" )
    fi
}

radiolist_show() {
    __parameter_count_check 1 "$@"

    RSETUP_RADIOLIST_STATE_NEW=( "$(__dialog --radiolist "$1" "${RSETUP_RADIOLIST[@]}" 3>&1 1>&2 2>&3 3>&-)" )
}
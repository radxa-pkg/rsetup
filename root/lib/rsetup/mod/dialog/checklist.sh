#!/bin/bash

source "$ROOT_PATH/lib/rsetup/mod/dialog/basic.sh"

checklist_init() {
    __parameter_count_check 0 "$@"

    RSETUP_CHECKLIST=()
    RSETUP_CHECKLIST_STATE_OLD=()
    RSETUP_CHECKLIST_STATE_NEW=()
}

checklist_add() {
    __parameter_count_check 2 "$@"

    local ITEM=$1
    local STATUS=$2
    local TAG="$((${#RSETUP_CHECKLIST[@]} / 3))"

    __parameter_value_check "$STATUS" "ON" "OFF"

    RSETUP_CHECKLIST+=( "$TAG" "$ITEM" "$STATUS" )

    if [[ $STATUS == "ON" ]]
    then
        RSETUP_CHECKLIST_STATE_OLD+=( "$TAG" )
    fi
}

checklist_show() {
    __parameter_count_check 1 "$@"

    RSETUP_CHECKLIST_STATE_NEW=( "$(__dialog --checklist "$1" "${RSETUP_CHECKLIST[@]}" 3>&1 1>&2 2>&3 3>&-)" )
}
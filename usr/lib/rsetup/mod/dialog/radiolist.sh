# shellcheck shell=bash

# shellcheck disable=SC2120
radiolist_init() {
    __parameter_count_check 0 "$@"

    export RSETUP_RADIOLIST=()
    export RSETUP_RADIOLIST_STATE_OLD=()
    export RSETUP_RADIOLIST_STATE_NEW=()
}

radiolist_add() {
    __parameter_count_check 2 "$@"

    local item=$1
    local status=$2
    local tag="$((${#RSETUP_RADIOLIST[@]} / 3))"

    __parameter_value_check "$status" "ON" "OFF"

    RSETUP_RADIOLIST+=( "$tag" "$item" "$status" )

    if [[ $status == "ON" ]]
    then
        RSETUP_RADIOLIST_STATE_OLD+=( "$tag" )
    fi
}

radiolist_show() {
    __parameter_count_check 1 "$@"

    local output
    if output="$(__dialog --radiolist "$1" "${RSETUP_RADIOLIST[@]}" 3>&1 1>&2 2>&3 3>&-)"
    then
        read -r -a RSETUP_RADIOLIST_STATE_NEW <<< "$output"
    else
        return 1
    fi
}
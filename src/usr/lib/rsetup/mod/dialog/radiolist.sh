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

    if (( ${#RSETUP_RADIOLIST[@]} == 0))
    then
        return 2
    fi

    local output i
    if output="$(__dialog --radiolist "$1" "${RSETUP_RADIOLIST[@]}" 3>&1 1>&2 2>&3 3>&-)"
    then
        read -r -a RSETUP_RADIOLIST_STATE_NEW <<< "$output"
        for i in $(seq 2 3 ${#RSETUP_RADIOLIST[@]})
        do
            RSETUP_RADIOLIST[i]="OFF"
        done
        for i in "${RSETUP_CHECKLIST_STATE_NEW[@]}"
        do
            i="${i//\"}"
            RSETUP_RADIOLIST[i * 3 + 2]="ON"
        done
    else
        return 1
    fi
}

radiolist_getitem() {
    __parameter_count_check 1 "$@"

    echo "${RSETUP_RADIOLIST[$(( ${1//\"} * 3 + 1))]}"
}

radiolist_emptymsg() {
    __parameter_count_check 1 "$@"

    if (( ${#RSETUP_RADIOLIST[@]} == 0))
    then
        msgbox "$1"
    fi
}

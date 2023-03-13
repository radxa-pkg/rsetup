# shellcheck shell=bash

# shellcheck disable=SC2120
checklist_init() {
    __parameter_count_check 0 "$@"

    export RSETUP_CHECKLIST=()
    export RSETUP_CHECKLIST_VALUE=()
    export RSETUP_CHECKLIST_STATE_OLD=()
    export RSETUP_CHECKLIST_STATE_NEW=()
}

checklist_add() {
    local title="$1"
    local status="$2"
    local tag="$((${#RSETUP_CHECKLIST[@]} / 3))"
    local value="${3:-$title}"

    __parameter_value_check "$status" "ON" "OFF"

    RSETUP_CHECKLIST+=( "$tag" "$title" "$status" )
    RSETUP_CHECKLIST_VALUE+=( "$value" )

    if [[ $status == "ON" ]]
    then
        RSETUP_CHECKLIST_STATE_OLD+=( "$tag" )
    fi
}

checklist_show() {
    __parameter_count_check 1 "$@"

    if (( ${#RSETUP_CHECKLIST[@]} == 0))
    then
        return 2
    fi

    local output i
    if output="$(__dialog --checklist "$1" "${RSETUP_CHECKLIST[@]}" 3>&1 1>&2 2>&3 3>&-)"
    then
        read -r -a RSETUP_CHECKLIST_STATE_NEW <<< "$output"
        for i in $(seq 2 3 ${#RSETUP_CHECKLIST[@]})
        do
            RSETUP_CHECKLIST[$i]="OFF"
        done
        for i in "${RSETUP_CHECKLIST_STATE_NEW[@]}"
        do
            i="${i//\"}"
            RSETUP_CHECKLIST[$(( i * 3 + 2 ))]="ON"
        done
    else
        return 1
    fi
}

checklist_getitem() {
    __parameter_count_check 1 "$@"

    echo "${RSETUP_CHECKLIST_VALUE[${1//\"}]}"
}

checklist_emptymsg() {
    __parameter_count_check 1 "$@"

    if (( ${#RSETUP_CHECKLIST[@]} == 0))
    then
        msgbox "$1"
    fi
}

# shellcheck shell=bash

# shellcheck disable=SC2120
checklist_init() {
    __parameter_count_check 0 "$@"

    export RSETUP_CHECKLIST=()
    export RSETUP_CHECKLIST_STATE_OLD=()
    export RSETUP_CHECKLIST_STATE_NEW=()
}

checklist_add() {
    __parameter_count_check 2 "$@"

    local item=$1
    local status=$2
    local tag="$((${#RSETUP_CHECKLIST[@]} / 3))"

    __parameter_value_check "$status" "ON" "OFF"

    RSETUP_CHECKLIST+=( "$tag" "$item" "$status" )

    if [[ $status == "ON" ]]
    then
        RSETUP_CHECKLIST_STATE_OLD+=( "$tag" )
    fi
}

checklist_show() {
    __parameter_count_check 1 "$@"

    local output
    if output="$(__dialog --checklist "$1" "${RSETUP_CHECKLIST[@]}" 3>&1 1>&2 2>&3 3>&-)"
    then
        read -r -a RSETUP_CHECKLIST_STATE_NEW <<< "$output"
    else
        return 1
    fi
}

checklist_getitem() {
    __parameter_count_check 1 "$@"

    echo "${RSETUP_CHECKLIST[$(( ${1//\"} * 3 + 1))]}"
}

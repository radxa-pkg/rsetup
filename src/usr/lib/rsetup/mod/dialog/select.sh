# shellcheck shell=bash

select_init() {
    export SELECT_TARGET_DIR="$1"
    export SELECT_FOLDER_ONLY="${2:-false}"
    export SELECT_RESULT=
}

__select_handler() {
    if $SELECT_FOLDER_ONLY
    then
        if [[ "$RSETUP_MENU_SELECTED" != "." ]]
        then
            SELECT_TARGET_DIR="$(realpath "$SELECT_TARGET_DIR/$RSETUP_MENU_SELECTED")"
        else
            SELECT_RESULT="$SELECT_TARGET_DIR"
        fi
    else
        if [[ -d "$SELECT_TARGET_DIR/$RSETUP_MENU_SELECTED" ]]
        then
            SELECT_TARGET_DIR="$(realpath "$SELECT_TARGET_DIR/$RSETUP_MENU_SELECTED")"
        else
            SELECT_RESULT="$SELECT_TARGET_DIR/$RSETUP_MENU_SELECTED"
        fi
    fi
}

__select_dialog() {
    local FIND_FILTER=()

    if $SELECT_FOLDER_ONLY
    then
        FIND_FILTER+=( "-type" "d" )
    fi

    while [[ -z "$SELECT_RESULT" ]]
    do
        menu_init

        while read -r
        do
            menu_add __select_handler "$REPLY"
        done < <(find "$SELECT_TARGET_DIR/." -maxdepth 1 "${FIND_FILTER[@]}" \( -type d \( -name '.' -printf ".\n" , ! -name '.' -printf "%P/\n" \) , ! -type d -printf "%P\n" \) | cat - <(echo "..") | sort -V)
        if $SELECT_FOLDER_ONLY
        then
            local msg="Please navigate to a folder under $SELECT_TARGET_DIR
Or choose . entry to select current folder."
        else
            local msg="Please select a file from $SELECT_TARGET_DIR"
        fi

        if ! menu_call "$msg"
        then
            return 1
        fi
    done

    echo "$SELECT_RESULT"
}

fselect() {
    __parameter_count_check 1 "$@"
    select_init "$1"
    __select_dialog
}

dselect() {
    __parameter_count_check 1 "$@"
    select_init "$1" "true"
    __select_dialog
}
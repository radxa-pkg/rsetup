# shellcheck shell=bash

ALLOWED_RCONFIG_FUNC+=("request_reboot")

RCONFIG_REBOOT="false"

request_reboot() {
    RCONFIG_REBOOT="${1:-true}"
}

process_config() {
    while read -r
    do
        local cmd
        cmd="$(awk '{print $1}' <<< "$REPLY")"

        if [[ "$cmd" == \#* ]] || [[ -z "$cmd" ]]
        then
            continue
        fi
        
        if [[ $(type -t "$cmd") == function ]] && __in_array "$cmd" "${ALLOWED_RCONFIG_FUNC[@]}"
        then
            echo "Running $cmd with $*..."
            if [[ "$DEBUG" == "1" ]]
            then
                echo "$REPLY"
            else
                exec $REPLY
            fi
        else
            echo "'$cmd' is not an allowed command."
        fi
    done < <(grep "" "$1")
}

__on_boot() {
    __parameter_count_check 0 "$@"

    local conf_dir="$ROOT_PATH/config"

    for i in "$conf_dir/before.txt" "$conf_dir/config.txt" "$conf_dir/after.txt"
    do
        if [[ -e "$i" ]]
        then
            process_config "$i"
        fi
    done

    rm -f "$conf_dir/before.txt" "$conf_dir/after.txt"

    if [[ "$RCONFIG_REBOOT" == "true" ]]
    then
        reboot
    fi
}
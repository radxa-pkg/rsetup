# shellcheck shell=bash

ALLOWED_RCONFIG_FUNC+=("request_reboot")

RCONFIG_REBOOT="false"

rconfig_allowed_func() {
    if [[ $(type -t "$1") != function ]] || ! __in_array "$1" "${ALLOWED_RCONFIG_FUNC[@]}" >/dev/null
    then
        echo "'$1' is not an allowed command."
        return 1
    fi
}

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

        if rconfig_allowed_func "$cmd"
        then
            echo "Running $cmd with $*..."
            if $DEBUG
            then
                echo "$REPLY"
            else
                eval "$REPLY"
            fi
        fi
    done < <(grep "" "$1")
}

__on_boot() {
    __parameter_count_check 0 "$@"

    local conf_dir="/config"

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
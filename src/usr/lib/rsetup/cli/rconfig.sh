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
    local argv
    while read -r
    do
        read -r -a argv <<< "$REPLY"

        case "${argv[0]}"
        in
            \#*|"")
                continue
                ;;
        then
            continue
        fi
        esac

        if rconfig_allowed_func "${argv[0]}"
        then
            echo "Running ${argv[0]} with" "${argv[@]:1}" "..."
            if $DEBUG
            then
                echo "${argv[*]}"
            else
                "${argv[@]}"
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
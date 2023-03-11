# shellcheck shell=bash

config_transaction_start() {
    RBUILD_CONFIG="/config/config.txt.new"
    cp /config/config.txt "$RBUILD_CONFIG"
}

config_transaction_abort() {
    rm -f "$RBUILD_CONFIG"
    unset RBUILD_CONFIG
}

config_transaction_commit() {
    cp /config/config.txt /config/config.txt.old
    mv "$RBUILD_CONFIG" /config/config.txt
    unset RBUILD_CONFIG
}

remove_config() {
    local regex="$1"
    shift
    while (( $# > 0 ))
    do
        regex="$regex\s+$1"
        shift
    done
    sed -E -i "/^\s*$regex.*$/d" "$RBUILD_CONFIG"
}

add_config() {
    echo "$@" >> "$RBUILD_CONFIG"
}

enable_config() {
    "$@"
    add_config "$@"
}

save_unique_config() {
    local command="$1"
    shift
    local arguments=( "$@" )
    config_transaction_start
    remove_config "$command"
    add_config "$command" "${arguments[@]}"
    config_transaction_commit
}

enable_unique_config() {
    local command="$1"
    shift
    local arguments=( "$@" )
    "$command" "${arguments[@]}"
    save_unique_config "$command" "${arguments[@]}"
}

# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/mod/hwid.sh
source "/usr/lib/rsetup/mod/hwid.sh"

get_setup_script() {
    local pid setup_script
    pid="${1:-$(get_product_id)}"
    for path in /usr/lib/{u-boot,edk2/*}/$pid/setup.sh; do
        if [[ -f "$path" ]]; then
            setup_script="$path"
            break
        fi
    done

    if [[ -z "${setup_script:-}" ]]; then
        echo "This operation requires a setup script to work!" >&2
        return 1
    fi

    echo "$setup_script"
}

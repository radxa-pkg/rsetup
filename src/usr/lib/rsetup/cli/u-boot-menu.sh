# shellcheck shell=bash

ALLOWED_RCONFIG_FUNC+=("load_u-boot_setting")

load_u-boot_setting() {
    if [[ ! -e "/etc/default/u-boot" ]]
    then
        touch "/etc/default/u-boot"
    fi

    # shellcheck source=/dev/null
    source "/etc/default/u-boot"

    if [[ -z "${U_BOOT_TIMEOUT:-}" ]]
    then
        if ! grep -q "^U_BOOT_TIMEOUT" "/etc/default/u-boot"
        then
            echo 'U_BOOT_TIMEOUT="10"' >> "/etc/default/u-boot"
        fi
        sed -i "s/^U_BOOT_TIMEOUT=.*/U_BOOT_TIMEOUT=\"10\"/g" "/etc/default/u-boot"
    fi
    if [[ -z "${U_BOOT_PARAMETERS:-}" ]]
    then
        if ! grep -q "^U_BOOT_PARAMETERS" "/etc/default/u-boot"
        then
            echo "U_BOOT_PARAMETERS=\"\$(cat \"\/etc/kernel/cmdline\")\"" >> "/etc/default/u-boot"
        fi
        sed -i "s|^U_BOOT_PARAMETERS=.*|U_BOOT_PARAMETERS=\"\$(cat /etc/kernel/cmdline)\"|g" "/etc/default/u-boot"
    fi

    # shellcheck source=/dev/null
    source "/etc/default/u-boot"

    if [[ -z "${U_BOOT_FDT_OVERLAYS_DIR:-}" ]]
    then
        eval "$(grep "^U_BOOT_FDT_OVERLAYS_DIR" "$(which u-boot-update)")"
        U_BOOT_FDT_OVERLAYS_DIR="${U_BOOT_FDT_OVERLAYS_DIR:-}"
    fi
}

disable_overlays() {
    load_u-boot_setting

    for i in "$U_BOOT_FDT_OVERLAYS_DIR"/*.dtbo
    do
        mv -- "$i" "${i}.disabled"
    done
}

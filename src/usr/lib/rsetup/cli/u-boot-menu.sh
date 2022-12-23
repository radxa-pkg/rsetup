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

__reset_overlays_worker() {
    local overlay="$1" output="$2"

    if dtbo_is_compatible "$overlay"
    then
        cp "$overlay" "$output"
    fi
}

reset_overlays() {
    local new_overlays dtbos=( "/usr/lib/linux-image-$(uname -r)/$(get_soc_vendor)/overlays/"/*.dtbo* ) i
    new_overlays="$(realpath U_BOOT_FDT_OVERLAYS_DIR)_new"
    mkdir -p "$new_overlays"
    for i in "${dtbos[@]}"
    do
        __reset_overlays_worker "$i" "$new_overlays" &
    done
    wait
    rm -rf "$U_BOOT_FDT_OVERLAYS_DIR"
    mv "$new_overlays" "$U_BOOT_FDT_OVERLAYS_DIR"
    disable_overlays
}

parse_dtbo() {
    dtc -I dtb -O dts "$1" 2>/dev/null | dtc -I dts -O yaml 2>/dev/null | yq -r ".[0].metadata.$2[0]" | xargs -0
}

dtbo_is_compatible() {
    local overlay="$1" dtbo_compatible

    if ! dtbo_compatible="$(parse_dtbo "$overlay" "compatible")"
    then
        return 1
    fi

    for d in $dtbo_compatible
    do
        for p in $(xargs -0 < /sys/firmware/devicetree/base/compatible)
        do
            if [[ "$d" == "$p" ]]
            then
                return
            fi
        done
    done

    return 1
}

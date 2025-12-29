# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/mod/overlay.sh
source "/usr/lib/rsetup/mod/overlay.sh"

ALLOWED_RCONFIG_FUNC+=("load_u-boot_setting")

load_u-boot_setting() {
    # shellcheck source=/dev/null
    source "/etc/default/u-boot"

    if [[ -z "${U_BOOT_FDT_OVERLAYS_DIR:-}" ]]; then
        if [[ -f /usr/share/u-boot-menu/read-config ]]; then
            U_BOOT_FDT_OVERLAYS_DIR="$(set +u; . /usr/share/u-boot-menu/read-config && echo "$U_BOOT_FDT_OVERLAYS_DIR")"
        else
            eval "$(grep "^U_BOOT_FDT_OVERLAYS_DIR" "$(which u-boot-update)")"
        fi
        U_BOOT_FDT_OVERLAYS_DIR="${U_BOOT_FDT_OVERLAYS_DIR:-}"
    fi

    FDT_OVERLAYS_DIR="${U_BOOT_FDT_OVERLAYS_DIR:-}"

    if [[ -z "$FDT_OVERLAYS_DIR" ]]; then
        echo "Warning: U-Boot overlays directory not found." >&2
        return 1
    fi
}

is_u-boot_exist() {
    command -v u-boot-update &>/dev/null && load_u-boot_setting
}

disable_u-boot_overlays() {
    if ! load_u-boot_setting; then
        return 1
    fi
    disable_overlays_general
}

rebuild_u-boot_overlays() {
    if ! load_u-boot_setting; then
        return 1
    fi
    rebuild_overlays_general "$@"
}

enable_u-boot_overlays() {
    __parameter_count_at_least_check 1 "$@"
    if ! load_u-boot_setting; then
        return 1
    fi
    enable_overlay_general "$@"
    u-boot-update
}

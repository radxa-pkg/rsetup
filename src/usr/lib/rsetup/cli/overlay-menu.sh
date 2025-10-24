# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/cli/edk2-menu.sh
source "/usr/lib/rsetup/cli/edk2-menu.sh"
# shellcheck source=src/usr/lib/rsetup/cli/u-boot-menu.sh
source "/usr/lib/rsetup/cli/u-boot-menu.sh"

load_overlay_setting() {
    if is_u-boot_exist; then
        load_u-boot_setting
    fi

    if is_edk2_exist; then
        load_edk2_setting
    fi
}

update_overlay_entry() {
    if is_u-boot_exist; then
        u-boot-update
    fi

    if is_edk2_exist; then
        update_entry_overlays
    fi
}

disable_overlays() {
    if is_u-boot_exist; then
        disable_u-boot_overlays
    fi

    if is_edk2_exist; then
        disable_edk2_overlays
    fi
}

rebuild_overlays() {
    local version
    version="${1:-}"

    if is_u-boot_exist; then
        rebuild_u-boot_overlays "$@"
    fi

    if is_edk2_exist "$version"; then
        rebuild_edk2_overlays "$@"
    fi
}

enable_overlays() {
    __parameter_count_at_least_check 1 "$@"

    if is_u-boot_exist; then
        enable_u-boot_overlays "$@"
    fi

    if is_edk2_exist; then
        enable_edk2_overlays "$@"
    fi
}

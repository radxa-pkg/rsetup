# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/mod/overlay.sh
source "/usr/lib/rsetup/mod/overlay.sh"

ALLOWED_RCONFIG_FUNC+=("load_edk2_setting")

load_edk2_setting() {
    local version="${1:-$(uname -r)}"
    local boot_kernel_dir="/boot/efi/$(< /etc/kernel/entry-token)/$version"
    if [[ -d "$boot_kernel_dir" ]]; then
        FDT_OVERLAYS_DIR="$boot_kernel_dir/dtbo"
    fi

    if [[ -z "$FDT_OVERLAYS_DIR" ]]; then
        echo "Warning: EDK2 overlays directory not found." >&2
        return 1
    fi
}

is_edk2_exist() {
    command -v bootctl &>/dev/null && bootctl list &>/dev/null && load_edk2_setting
}

update_entry_overlays() {
    local version="${1:-$(uname -r)}"

    if ! load_edk2_setting "$version"; then
        return 1
    fi

    local product="${2:-$(get_product_id)}"

    local entry_token
    if [[ -f "/etc/kernel/entry-token" ]]; then
        entry_token="$(< /etc/kernel/entry-token)"
    else
        echo "Error: /etc/kernel/entry-token not found." >&2
        return 1
    fi

    local boot_root="/boot/efi"
    local entry_dir="/$entry_token/$version"
    local entry_dir_abs="$boot_root/$entry_dir"
    local dtbo_list=()

    for i in "$FDT_OVERLAYS_DIR"/*.dtbo; do
        if [[ -f "$i" ]]; then
            dtbo_list+=("$entry_dir/dtbo/$(basename "$i")")
        fi
    done

    local dtb
    dtb=$(find "/usr/lib/linux-image-$version/" -name "*${product}.dtb" | head -n 1)

    if [[ -z "$dtb" ]]; then
        echo "Warning: Unable to find device tree blob for '$product'." >&2
        echo "Warning: No overlay will be configured." >&2
        return 1
    fi

    cp "$dtb" "$entry_dir_abs/"
    local dtb_path="$entry_dir/$(basename "$dtb")"

    local tries_file="/etc/kernel/tries"
    local loader_entry

    if [[ -f "$tries_file" ]]; then
        local tries
        read -r tries < "$tries_file"
        if ! [[ "$tries" =~ ^[0-9]+$ ]]; then
            echo "Error: $tries_file does not contain a valid integer." >&2
            return 1
        fi
        loader_entry="$boot_root/loader/entries/$entry_token-$version+$tries.conf"
    else
        loader_entry="$boot_root/loader/entries/$entry_token-$version.conf"
    fi

    if [[ ! -f "$loader_entry" ]]; then
        echo "Error: Loader entry '$loader_entry' not found." >&2
        return 1
    fi

    sed -i '/^devicetree /d; /^devicetree-overlay /d' "$loader_entry"

    {
        echo "devicetree $dtb_path"
        if (( ${#dtbo_list[@]} > 0 )); then
            echo "devicetree-overlay ${dtbo_list[*]}"
        fi
    } >> "$loader_entry" || {
        echo "Error: Could not update loader entry '$loader_entry'." >&2
        return 1
    }

    echo "Successfully updated overlays for kernel $version"
}

disable_edk2_overlays() {
    if ! load_edk2_setting; then
        return 1
    fi
    disable_overlays_general
}

rebuild_edk2_overlays() {
    local version="${1:-$(uname -r)}"
    if ! load_edk2_setting "$version"; then
        return 1
    fi
    rebuild_overlays_general "$@"
}

enable_edk2_overlays() {
    __parameter_count_at_least_check 1 "$@"
    if ! load_edk2_setting; then
        return 1
    fi
    enable_overlay_general "$@"
    update_entry_overlays
}

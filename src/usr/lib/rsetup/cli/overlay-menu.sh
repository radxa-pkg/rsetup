# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/cli/edk2-menu.sh
source "/usr/lib/rsetup/cli/edk2-menu.sh"
# shellcheck source=src/usr/lib/rsetup/cli/u-boot-menu.sh
source "/usr/lib/rsetup/cli/u-boot-menu.sh"

ALLOWED_RCONFIG_FUNC+=("overlay")

__overlay_resolve() {
    local input="$1" directory name

    if [[ -z "$input" ]]
    then
        echo "Empty overlay name is not valid." >&2
        return 1
    fi

    input="${input%.disabled}"
    if [[ "$input" != *.dtbo ]]
    then
        input="$input.dtbo"
    fi

    directory="$(dirname -- "$input")"
    if [[ "$directory" == . ]]
    then
        directory="$FDT_OVERLAYS_DIR"
    elif [[ "$(realpath -e -- "$directory" 2>/dev/null)" != "$(realpath -e -- "$FDT_OVERLAYS_DIR")" ]]
    then
        echo "$1: only overlays within '$FDT_OVERLAYS_DIR' can be managed." >&2
        return 1
    fi

    name="$(basename -- "$input")"
    if [[ ! -f "$directory/$name" && ! -f "$directory/$name.disabled" ]]
    then
        echo "$1: cannot find such overlay in '$FDT_OVERLAYS_DIR'" >&2
        return 1
    fi
    echo "$name"
}

__overlay_validate() {
    (
        msgbox() { echo "$1" >&2; }
        # shellcheck disable=SC2329
        yesno() { return 0; }

        local name title package

        check_overlay_conflict_init
        for name in "$@"
        do
            check_overlay_conflict "$FDT_OVERLAYS_DIR/$name"* || return 1
            mapfile -t title < <(parse_dtbo --default-value "file" "title" "$FDT_OVERLAYS_DIR/$name"*)
            mapfile -t package < <(parse_dtbo "package" "$FDT_OVERLAYS_DIR/$name"*)
            if [[ "${package[0]:-null}" != null ]] && ! __depends_package "${title[0]}" "${package[@]}"
            then
                echo "Failed to install required packages for '${title[0]}'." >&2
                return 1
            fi
        done
    )
}

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
        u-boot-update || return $?
    fi

    if is_edk2_exist; then
        update_entry_overlays || return $?
    fi
}

disable_overlays() {
    if is_u-boot_exist; then
        disable_u-boot_overlays || return $?
    fi

    if is_edk2_exist; then
        disable_edk2_overlays || return $?
    fi
}

rebuild_overlays() {
    local version="${1:-}"

    if is_u-boot_exist; then
        rebuild_u-boot_overlays "$@" || return $?
    fi

    if is_edk2_exist "$version"; then
        rebuild_edk2_overlays "$@" || return $?
    fi
}

enable_overlays() {
    __parameter_count_at_least_check 1 "$@" || return $?

    if is_u-boot_exist; then
        enable_u-boot_overlays "$@" || return $?
    fi

    if is_edk2_exist; then
        enable_edk2_overlays "$@" || return $?
    fi
}

__apply_overlays() {
    disable_overlays || return $?

    if (( $# == 0 ))
    then
        update_overlay_entry
    else
        enable_overlays "$@"
    fi
}

__overlay_usage() {
    echo "Usage: rsetup overlay [--enable|--disable] <overlay>..." >&2
    echo "  --enable, -e   enable the given overlays" >&2
    echo "  --disable, -d  disable the given overlays" >&2
    echo "Without either option, each overlay is toggled by its current state." >&2
}

overlay() {
    local mode=toggle argument name path
    local operands=() selected=() seen=() messages=()

    for argument in "$@"
    do
        case "$argument" in
            --enable|-e)
                [[ "$mode" != disable ]] || { __overlay_usage; return "$ERROR_ILLEGAL_PARAMETERS"; }
                mode=enable
                ;;
            --disable|-d)
                [[ "$mode" != enable ]] || { __overlay_usage; return "$ERROR_ILLEGAL_PARAMETERS"; }
                mode=disable
                ;;
            --help|-h)
                __overlay_usage
                return 0
                ;;
            -*)
                echo "$argument: unknown option." >&2
                __overlay_usage
                return "$ERROR_ILLEGAL_PARAMETERS"
                ;;
            *)
                operands+=("$argument")
                ;;
        esac
    done

    if (( ${#operands[@]} == 0 ))
    then
        __overlay_usage
        return "$ERROR_REQUIRE_PARAMETER"
    elif (( EUID != 0 ))
    then
        echo "Root privileges are required, run this command with sudo." >&2
        return 1
    fi

    load_overlay_setting
    if [[ -n "${U_BOOT_FDT_OVERLAYS:-}" ]]
    then
        echo "Detected 'U_BOOT_FDT_OVERLAYS' in '/etc/default/u-boot'." >&2
        echo "Overlay feature is temporarily disabled until such customization is reverted." >&2
        return 1
    elif [[ -z "${FDT_OVERLAYS_DIR:-}" ]]
    then
        echo "No supported boot loader found, unable to configure overlays." >&2
        return 1
    fi

    for path in "$FDT_OVERLAYS_DIR"/*.dtbo
    do
        selected+=("$(basename -- "$path")")
    done

    for argument in "${operands[@]}"
    do
        name="$(__overlay_resolve "$argument")" || return "$ERROR_ILLEGAL_PARAMETERS"
        if __in_array "$name" "${seen[@]}" >/dev/null
        then
            continue
        fi
        seen+=("$name")

        if [[ "$mode" == enable ]]
        then
            __in_array "$name" "${selected[@]}" >/dev/null || selected+=("$name")
            messages+=("Enabled: $name")
        elif [[ "$mode" == disable ]] || __in_array "$name" "${selected[@]}" >/dev/null
        then
            __array_remove selected "$name"
            messages+=("Disabled: $name")
        else
            selected+=("$name")
            messages+=("Enabled: $name")
        fi
    done

    if (( ${#selected[@]} != 0 ))
    then
        __overlay_validate "${selected[@]}" || return $?
    fi
    __apply_overlays "${selected[@]}" || return $?
    printf '%s\n' "${messages[@]}"
}

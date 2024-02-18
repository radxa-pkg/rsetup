# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/mod/overlay.sh
source "/usr/lib/rsetup/mod/overlay.sh"

ALLOWED_RCONFIG_FUNC+=("load_u-boot_setting")

check_overlay_conflict_init() {
    RSETUP_OVERLAY_RESOURCES=()
    RSETUP_OVERLAY_RESOURCE_OWNER=()
}

check_overlay_conflict() {
    local name resources res i
    mapfile -t resources < <(parse_dtbo "exclusive" "$1")
    mapfile -t name < <(parse_dtbo --default-value "file" "title" "$1")

    for res in "${resources[@]}"
    do
        if [[ "$res" == "null" ]]
        then
            continue
        fi
        if i="$(__in_array "$res" "${RSETUP_OVERLAY_RESOURCES[@]}")"
        then
            msgbox "Resource conflict detected!

'${name[0]}' and '${RSETUP_OVERLAY_RESOURCE_OWNER[$i]}' both require the exclusive ownership of the following resource:

${RSETUP_OVERLAY_RESOURCES[$i]}

Please only enable one of them."
            return 1
        else
            RSETUP_OVERLAY_RESOURCES+=("$res")
            RSETUP_OVERLAY_RESOURCE_OWNER+=("${name[0]}")
        fi
    done
}

load_u-boot_setting() {
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

rebuild_overlays() {
    load_u-boot_setting

    local version="$1" vendor="$2" dtbos i
    local old_overlays new_overlays enabled_overlays=()
    old_overlays="$(realpath "$U_BOOT_FDT_OVERLAYS_DIR")"
    new_overlays="${old_overlays}_new"
    if [[ -d "$old_overlays" ]]
    then
        cp -aR "$old_overlays" "$new_overlays"
    else
        mkdir -p "$old_overlays" "$new_overlays"
    fi

    if [[ -f "$new_overlays/managed.list" ]]
    then
        mapfile -t RSETUP_MANAGED_OVERLAYS < "$new_overlays/managed.list"

        for i in "${RSETUP_MANAGED_OVERLAYS[@]}"
        do
            if [[ -f "$new_overlays/$i" ]]
            then
                enabled_overlays+=( "$i" )
                rm -f "$new_overlays/$i"
            fi
            rm -f "$new_overlays/$i.disabled"
        done
    fi

    if [[ -n "$vendor" ]]
    then
        dtbos=( "/usr/lib/linux-image-$version/$vendor/overlays/"*.dtbo* )
    else
        dtbos=( "/usr/lib/linux-image-$version/"*"/overlays/"*.dtbo* )
    fi
    rm -f "$new_overlays/managed.list"
    touch "$new_overlays/managed.list"

    mapfile -t dtbos < <(dtbo_is_compatible "${dtbos[@]}")

    for i in "${dtbos[@]}"
    do
        cp "$i" "$new_overlays/$(basename "$i").disabled"
        basename "$i" >> "$new_overlays/managed.list"
    done
    wait

    for i in "${enabled_overlays[@]}"
    do
        if [[ -f "$new_overlays/${i}.disabled" ]]
        then
            mv -- "$new_overlays/${i}.disabled" "$new_overlays/$i"
        fi
    done

    rm -rf "${old_overlays}_old"
    mv "$old_overlays" "${old_overlays}_old"
    mv "$new_overlays" "$old_overlays"
}

enable_overlays() {
    __parameter_count_at_least_check 1 "$@"

    local enable_overlays_list i dir_name file_name input_check=true

    load_u-boot_setting

    for i in "$@"
    do
        dir_name="$(dirname "$i")"
        file_name="$(basename "${i%.disabled}")"

        if [[ "$dir_name" == "." ]]
        then
            dir_name="$U_BOOT_FDT_OVERLAYS_DIR"
        fi

        if [[ "$(realpath "$dir_name")" != "$(realpath "$U_BOOT_FDT_OVERLAYS_DIR")" ]]
        then
            echo "$i: only overlays within '$U_BOOT_FDT_OVERLAYS_DIR' can be enabled." >&2
            input_check=false
        elif [[ -e "$dir_name/$file_name.disabled" ]]
        then
            enable_overlays_list+=("$U_BOOT_FDT_OVERLAYS_DIR/$file_name")
        elif [[ -e "$dir_name/$file_name" ]]
        then
            echo "$file_name: already enabled." >&2
        else
            echo "$file_name: cannot find such overlay in '$U_BOOT_FDT_OVERLAYS_DIR'"
            input_check=false
        fi
    done

    if ! $input_check
    then
        return "$ERROR_ILLEGAL_PARAMETERS"
    fi

    for i in "${enable_overlays_list[@]}"
    do
        mv "$i.disabled" "$i"
    done

    u-boot-update
}

# shellcheck shell=bash

compile_dtb() {
    local temp dts="$1" dtbo="${2:-${1%.dts}.dtbo}"
    temp="$(mktemp)"
    # shellcheck disable=SC2064
    trap "rm -f $temp" RETURN EXIT

    if ! cpp -nostdinc -undef -x assembler-with-cpp -E -I "/usr/src/linux-headers-$(uname -r)/include" -I "/usr/lib/modules/$(uname -r)/build/include" "$dts" "$temp"
    then
        return 1
    fi

    if ! dtc -q -@ -I dts -O dtb -o "$dtbo" "$temp"
    then
        return 2
    fi
}

is_overlay_unchanged() {
    [[ "$(__array_to_ordered_text "${RTUI_CHECKLIST_STATE_NEW[@]}")" == \
       "$(__array_to_ordered_text "${RTUI_CHECKLIST_STATE_OLD[@]}")" ]]
}

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

disable_overlays_general() {
    for i in "$FDT_OVERLAYS_DIR"/*.dtbo
    do
        mv -- "$i" "${i}.disabled"
    done
}

rebuild_overlays_general() {
    local version="$1" vendor="${2:-}" dtbos i
    local old_overlays new_overlays enabled_overlays=()

    old_overlays="$(realpath "$FDT_OVERLAYS_DIR")"
    new_overlays="${old_overlays}_new"

    echo "Rebuilding overlay data folder for '$version'..."

    if [[ -d "$old_overlays" ]]
    then
        cp -aR "$old_overlays" "$new_overlays"
    else
        mkdir -p "$old_overlays" "$new_overlays"
    fi

    if [[ -f "$new_overlays/managed.list" ]]
    then
        echo "Removing managed overlays..."
        mapfile -t RSETUP_MANAGED_OVERLAYS < "$new_overlays/managed.list"

        for i in "${RSETUP_MANAGED_OVERLAYS[@]}"
        do
            if [[ -f "$new_overlays/$i" ]]
            then
                enabled_overlays+=( "$i" )
            fi
            rm -f "$new_overlays/$i" "$new_overlays/$i.disabled"
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

    echo "Building list of compatible overlays..."
    mapfile -t dtbos < <(dtbo_is_compatible "${dtbos[@]}")

    # This loop is a bottleneck due to expensive operations
    # Enabling parallelism brings total execution time from 38.453s to 21.633s
    local nproc
    nproc=$(( $(nproc) ))
    echo "Installing compatible overlays..."
    for i in "${dtbos[@]}"
    do
        while (( $(jobs -r | wc -l) > nproc ))
        do
            sleep 0.1
        done
        (
            cp "$i" "$new_overlays/$(basename "$i").disabled"
            exec 100>>"$new_overlays/managed.list"
            flock 100
            basename "$i" >&100
        ) &
    done
    wait

    # This loop is not a bottleneck
    # We add parallelism to make it uniform
    echo "Reenable previously enabled overlays..."
    for i in "${enabled_overlays[@]}"
    do
        while (( $(jobs -r | wc -l) > nproc ))
        do
            sleep 0.1
        done
        (
            if [[ -f "$new_overlays/${i}.disabled" ]]
            then
                mv -- "$new_overlays/${i}.disabled" "$new_overlays/$i"
            fi
        ) &
    done
    wait

    echo "Commiting changes..."
    rm -rf "${old_overlays}_old"
    mv "$old_overlays" "${old_overlays}_old"
    mv "$new_overlays" "$old_overlays"

    echo "Overlay data folder has been successfully rebuilt."
}

enable_overlay_general() {
    __parameter_count_at_least_check 1 "$@"

    local enable_overlays_list i dir_name file_name input_check=true

    for i in "$@"
    do
        dir_name="$(dirname "$i")"
        file_name="$(basename "${i%.disabled}")"

        if [[ "$dir_name" == "." ]]
        then
            dir_name="$FDT_OVERLAYS_DIR"
        fi

        if [[ "$(realpath "$dir_name")" != "$(realpath "$FDT_OVERLAYS_DIR")" ]]
        then
            echo "$i: only overlays within '$FDT_OVERLAYS_DIR' can be enabled." >&2
            input_check=false
        elif [[ -e "$dir_name/$file_name.disabled" ]]
        then
            enable_overlays_list+=("$FDT_OVERLAYS_DIR/$file_name")
        elif [[ -e "$dir_name/$file_name" ]]
        then
            echo "$file_name: already enabled." >&2
        else
            echo "$file_name: cannot find such overlay in '$FDT_OVERLAYS_DIR'"
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
}

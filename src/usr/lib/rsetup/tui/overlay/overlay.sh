# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/mod/hwid.sh
source "/usr/lib/rsetup/mod/hwid.sh"
source "/usr/lib/rsetup/mod/pkg.sh"
source "/usr/lib/rsetup/mod/overlay.sh"

__overlay_install() {
    if ! __depends_package "Install 3rd party overlay" "gcc" "linux-headers-$(uname -r)"
    then
        return
    fi

    if ! yesno "3rd party overlay could physically damage your system.
In addition, they may miss important metadata for rsetup to recognize correctly.
This means if you ever run 'Manage overlay' function again, your custom overlays
might be disabled, and you will have to manually reenable them.

Are you sure?"
    then
        return
    fi

    local item basename err=0
    if ! item="$(fselect "$PWD")"
    then
        return
    fi

    load_u-boot_setting

    basename="$(basename "$item")"

    case $basename in
        *.dtbo)
            cp "$item" "$U_BOOT_FDT_OVERLAYS_DIR/$basename"
            ;;
        *.dts|*.dtso)
            basename="${basename%.dts*}.dtbo"

            compile_dtb "$item" "$U_BOOT_FDT_OVERLAYS_DIR/$basename" || err=$?
            case $err in
                0) : ;;
                1)
                    msgbox "Unable to preprocess the source code!"
                    return
                    ;;
                2)
                    msgbox "Unable to compile the source code!"
                    return
                    ;;
                *)
                    msgbox "Unknown error $err occured during compilation."
                    return
                    ;;
            esac
            ;;
        *)
            msgbox "Unknown file format: $basename"
            return
            ;;
    esac

    if u-boot-update >/dev/null
    then
        msgbox "Selected overlays will be enabled at next boot."
    else
        msgbox "Unable to update the boot config."
    fi
}

__overlay_filter_worker() {
    local temp="$1" overlay="$2" state title overlay_name

    if ! dtbo_is_compatible "$overlay"
    then
        return
    fi

    exec 100>> "$temp"
    flock 100

    if [[ "$overlay" == *.dtbo ]]
    then
        state="ON"
    elif [[ "$overlay" == *.dtbo.disabled ]]
    then
        state="OFF"
    else
        return
    fi

    overlay_name="$(basename "$overlay" | sed -E "s/(.*\.dtbo).*/\1/")"
    mapfile -t title < <(parse_dtbo "$overlay" "title" "$overlay_name")

    echo -e "${title[0]}\0${state}\0${overlay_name}" >&100
}

__overlay_filter() {
    local temp="$1" nproc index
    local dtbos=( "$U_BOOT_FDT_OVERLAYS_DIR"/*.dtbo* )
    mapfile -t index < <(eval "echo {0..$(( ${#dtbos[@]} - 1 ))}" | tr ' ' '\n')
    nproc=$(nproc)

    for i in "${index[@]}"
    do
        while (( $(jobs -r | wc -l) > nproc ))
        do
            sleep 0.1
        done

        __overlay_filter_worker "$temp" "${dtbos[$i]}" &
        echo $(( i * 100 / (${index[-1]} + 1) ))
    done

    wait
}

__overlay_show() {
    local validation="${1:-true}"
    echo "Searching available overlays may take a while, please wait..." >&2
    load_u-boot_setting

    local temp
    temp="$(mktemp)"
    # shellcheck disable=SC2064
    trap "rm -f $temp" RETURN EXIT

    __overlay_filter "$temp" | gauge "Searching available overlays..." 0

    checklist_init
    # Bash doesn support IFS=$'\0'
    # Use array to emulate this
    local items=()
    mapfile -t items < <(sort "$temp" | tr $"\0" $"\n")
    while (( ${#items[@]} >= 3 ))
    do
        checklist_add "${items[0]/$'\n'}" "${items[1]/$'\n'}" "${items[2]/$'\n'}"
        items=("${items[@]:3}")
    done

    checklist_emptymsg "Unable to find any compatible overlay under $U_BOOT_FDT_OVERLAYS_DIR."

    while true
    do
        if ! checklist_show "Please select overlays:"
        then
            return 1
        fi

        if $validation
        then
            return
        fi
    done
}

__overlay_validate() {
    local i item
    check_overlay_conflict_init
    for i in "${RSETUP_CHECKLIST_STATE_NEW[@]}"
    do
        item="$(checklist_getitem "$i")"
        if ! check_overlay_conflict "$U_BOOT_FDT_OVERLAYS_DIR/$item"*
        then
            return 1
        fi

        local title package
        mapfile -t title < <(parse_dtbo "$U_BOOT_FDT_OVERLAYS_DIR/$item"* "title" "$(basename "$item")")
        mapfile -t package < <(parse_dtbo "$U_BOOT_FDT_OVERLAYS_DIR/$item"* "package")
        if [[ "${package[0]}" != "null" ]]
        then
            if ! __depends_package "${title[0]}" "${package[@]}"
            then
                msgbox "Failed to install required packages for '${title[0]}'."
                return 1
            fi
        fi
    done
}

__overlay_manage() {
    if ! __overlay_show __overlay_validate
    then
        return
    fi

    disable_overlays

    local item
    for i in "${RSETUP_CHECKLIST_STATE_NEW[@]}"
    do
        item="$(checklist_getitem "$i")"
        mv "$U_BOOT_FDT_OVERLAYS_DIR/$item.disabled" "$U_BOOT_FDT_OVERLAYS_DIR/$item"
    done

    if u-boot-update >/dev/null
    then
        msgbox "Selected overlays will be enabled at next boot."
    else
        msgbox "Unable to update the boot config."
    fi
}

__overlay_info() {
    if ! __overlay_show
    then
        return
    fi

    local item title category description exclusive package i
    for i in "${RSETUP_CHECKLIST_STATE_NEW[@]}"
    do
        item="$(checklist_getitem "$i")"
        mapfile -t title < <(parse_dtbo "$U_BOOT_FDT_OVERLAYS_DIR/$item"* "title")
        mapfile -t category < <(parse_dtbo "$U_BOOT_FDT_OVERLAYS_DIR/$item"* "category")
        mapfile -t exclusive < <(parse_dtbo "$U_BOOT_FDT_OVERLAYS_DIR/$item"* "exclusive")
        mapfile -t package < <(parse_dtbo "$U_BOOT_FDT_OVERLAYS_DIR/$item"* "package")
        description="$(parse_dtbo "$U_BOOT_FDT_OVERLAYS_DIR/$item"* "description")"
        if (( ${#title[@]} == 1 )) && [[ "${title[0]}" == "null" ]]
        then
            title=( "$item" )
            description="This is a 3rd party overlay. No metadata is available."
        fi
        if ! yesno "Title: ${title[0]}
Category: ${category[0]}
Exclusive: ${exclusive[*]}
Package: ${package[*]}
Description:

$description"
        then
            break
        fi
    done
}

__overlay_reset() {
    if ! yesno "WARNING

All installed overlays will be reset to current running kernel's default.
All enabled overlays will be disabled.
Any overlay that is not shipped with the running kernel will be removed."
    then
        return
    fi

    if reset_overlays "$(uname -r)" "$(get_soc_vendor)"
    then
        msgbox "Overlays has been reset to current running kernel's default."
    else
        msgbox "Unable to reset overlays"
    fi
}

__overlay() {
    RSETUP_OVERLAY_WARNING="${RSETUP_OVERLAY_WARNING:-true}"
    if [[ "$RSETUP_OVERLAY_WARNING" == "true" ]] && ! yesno "WARNING

Overlays, by its nature, require \"hidden\" knowledge about the running device tree.
While major breakage is unlikely, this does mean that after kernel update, the overlay may cease to work.

If you accept the risk, select Yes to continue.
Otherwise, select No to go back to previous menu."
    then
        return
    fi
    RSETUP_OVERLAY_WARNING="false"

    load_u-boot_setting

    if [[ -n "${U_BOOT_FDT_OVERLAYS:-}" ]]
    then
        msgbox \
"Detected 'U_BOOT_FDT_OVERLAYS' in '/etc/default/u-boot'.
This usually happens when you want to customize your boot process.
To avoid potential conflicts, overlay feature is temporarily disabled until such customization is reverted."
        return
    fi

    menu_init
    menu_add __overlay_manage "Manage overlays"
    menu_add __overlay_info "View overlay info"
    menu_add __overlay_install "Install 3rd party overlay"
    menu_add __overlay_reset "Reset overlays"
    menu_show "Configure Device Tree Overlay"
}

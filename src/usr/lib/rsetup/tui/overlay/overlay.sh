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

__overlay_show() {
    local validation="${1:-true}"
    infobox "Searching available overlays may take a while, please wait..."
    load_u-boot_setting

    local dtbos=( "$U_BOOT_FDT_OVERLAYS_DIR"/*.dtbo* )
    mapfile -t dtbos < <(dtbo_is_compatible "${dtbos[@]}")

    checklist_init
    # Bash doesn support IFS=$'\0'
    # Use array to emulate this
    local items=()
    mapfile -t items < <(parse_dtbo --show-overlays "title" "${dtbos[@]}")
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
        mapfile -t title < <(parse_dtbo --default-value "file"  "title" "$U_BOOT_FDT_OVERLAYS_DIR/$item"*)
        mapfile -t package < <(parse_dtbo "package" "$U_BOOT_FDT_OVERLAYS_DIR/$item"*)
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

    local items=() ret
    for i in "${RSETUP_CHECKLIST_STATE_NEW[@]}"
    do
        items+=("$(checklist_getitem "$i")")
    done

    if (( ${#items[@]} == 0 ))
    then
        return
    fi

    enable_overlays "${items[@]}"; ret="$?"
    case "$ret" in
        0)
            msgbox "Selected overlays will be enabled at next boot."
            ;;
        "$ERROR_ILLEGAL_PARAMETERS")
            msgbox "The selection contains non-existing overlays. Did you delete them?"
            ;;
        *)
            msgbox "Unable to update the boot config."
            ;;
    esac
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
        mapfile -t title < <(parse_dtbo "title" "$U_BOOT_FDT_OVERLAYS_DIR/$item"*)
        mapfile -t category < <(parse_dtbo "category" "$U_BOOT_FDT_OVERLAYS_DIR/$item"*)
        mapfile -t exclusive < <(parse_dtbo "exclusive" "$U_BOOT_FDT_OVERLAYS_DIR/$item"*)
        mapfile -t package < <(parse_dtbo "package" "$U_BOOT_FDT_OVERLAYS_DIR/$item"*)
        description="$(parse_dtbo "description" "$U_BOOT_FDT_OVERLAYS_DIR/$item"*)"
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

__overlay_rebuild() {
    if ! yesno "WARNING

This feature will rebuild the overlay folder.
Overlays *provided by Radxa* will be replaced by the one from the current running kernel,
and incompatible ones will be removed.

This operation will preserve the overlay enable status as much as possible,
and user supplied overlays will be untouched.

Are you sure?
"
    then
        return
    fi

    if rebuild_overlays "$(uname -r)" "$(get_soc_vendor)"
    then
        msgbox "Overlays have been reset."
    else
        msgbox "Unable to reset overlays."
    fi
}

__overlay() {
    if ! show_once "RSETUP_OVERLAY_WARNING" yesno "WARNING

Overlays, by its nature, require \"hidden\" knowledge about the running device tree.
While major breakage is unlikely, this does mean that after kernel update, the overlay may cease to work.

If you accept the risk, select Yes to continue.
Otherwise, select No to go back to previous menu."
    then
        return
    fi

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
    menu_add __overlay_rebuild "Rebuild overlays"
    menu_show "Configure Device Tree Overlay"
}

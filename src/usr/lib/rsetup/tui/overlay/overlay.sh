# shellcheck shell=bash

source "/usr/lib/rsetup/mod/hwid.sh"
source "/usr/lib/rsetup/mod/pkg.sh"

__overlay_parse_dtbo() {
    dtc -I dtb -O dts "$1" 2>/dev/null | dtc -I dts -O yaml 2>/dev/null | yq -r ".[0].metadata.$2[0]" | xargs -0
}

__overlay_is_compatible() {
    local overlay="$1" dtbo_compatible

    if ! dtbo_compatible="$(__overlay_parse_dtbo "$overlay" "compatible")"
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

__overlay_install() {
    if ! __depends_package "gcc" "linux-headers-$(uname -r)"
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

    local item basename temp
    if ! item="$(fselect "$PWD")"
    then
        return
    fi

    load_u-boot_setting

    basename="$(basename "$item")"
    basename="${basename%.dts}.dtbo"
    temp="$(mktemp)"
    # shellcheck disable=SC2064
    trap "rm -f $temp" RETURN EXIT

    if ! cpp -E -I "/usr/src/linux-headers-$(uname -r)/include" "$item" "$temp"
    then
        msgbox "Unable to preprocess the source code!"
        return
    fi

    if ! dtc -q -@ -I dts -O dtb -o "$U_BOOT_FDT_OVERLAYS_DIR/$basename" "$item"
    then
        msgbox "Unable to compile the source code!"
        return
    fi

    if ! u-boot-update >/dev/null
    then
        msgbox "Unable to update the boot config!"
        return
    fi
}

__overlay_filter() {
    local overlay="$1" temp="$2"

    if ! __overlay_is_compatible "$overlay"
    then
        return
    fi

    exec 100>> "$temp"
    flock 100

    if [[ "$i" == *.dtbo ]]
    then
        echo -e "$(__overlay_parse_dtbo "$overlay" "title")\0ON\0$(basename "$overlay")" >&100
    elif [[ "$i" == *.dtbo.disabled ]]
    then
        echo -e "$(__overlay_parse_dtbo "$overlay" "title")\0OFF\0$(basename "$overlay" | sed -E "s/(.*\.dtbo).*/\1/")" >&100
    fi
}

__overlay_manage() {
    echo "Fetching available overlays may take a while, please wait..." >&2
    load_u-boot_setting
    checklist_init

    local temp
    temp="$(mktemp)"
    # shellcheck disable=SC2064
    trap "rm -f $temp" RETURN EXIT
    for i in "$U_BOOT_FDT_OVERLAYS_DIR"/*.dtbo*
    do
        __overlay_filter "$i" "$temp" &
    done

    wait

    # Bash doesn support IFS=$'\0'
    # Use array to emulate this
    local items=()
    mapfile items < <(sort "$temp" | tr $"\0" $"\n")
    while (( ${#items[@]} >= 3 ))
    do
        checklist_add "${items[0]/$'\n'}" "${items[1]/$'\n'}" "${items[2]/$'\n'}"
        items=("${items[@]:3}")
    done

    checklist_emptymsg "Unable to find any compatible overlay under $U_BOOT_FDT_OVERLAYS_DIR."
    if ! checklist_show "Please select overlays you want to enable on boot:"
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

    if ! u-boot-update >/dev/null
    then
        msgbox "Unable to update the boot config!"
        return
    fi
}

__overlay_reset() {
    rm -rf "$U_BOOT_FDT_OVERLAYS_DIR"
    mkdir -p "$U_BOOT_FDT_OVERLAYS_DIR"
    cp -aR "/usr/lib/linux-image-$(uname -r)/$(get_soc_vendor)/overlays/." "$U_BOOT_FDT_OVERLAYS_DIR"
    disable_overlays
}

__overlay() {
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
    menu_add __overlay_manage "Manage overlay"
    menu_add __overlay_install "Install overlay from source"
    menu_add __overlay_reset "Reset installed overlay to kernel's default"
    menu_show "Configure Device Tree Overlay"
}
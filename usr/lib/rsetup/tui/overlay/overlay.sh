# shellcheck shell=bash

source "$ROOT_PATH/usr/lib/rsetup/mod/hwid.sh"

__overlay_install() {
    local item basename
    if ! item="$(fselect "$PWD")"
    then
        return
    fi

    load_u-boot_setting

    basename="$(basename "$item")"
    basename="${basename%.dts}.dtbo"
    if ! dtc -q -I dts -O dtb -o "$U_BOOT_FDT_OVERLAYS_DIR/$basename" "$item"
    then
        msgbox "Unable to compile the given device tree!"
        return
    fi

    __overlay_rebuild
}

__overlay_manage() {
    load_u-boot_setting
    checklist_init

    for i in "$U_BOOT_FDT_OVERLAYS_DIR"/*.dtbo*
    do
        if [[ "$i" == *.dtbo ]]
        then
            checklist_add "$(basename "$i")" "ON"
        elif [[ "$i" == *.dtbo.disabled ]]
        then
            checklist_add "$(basename "$i" | sed -E "s/(.*\.dtbo).*/\1/")" "OFF"
        fi
    done

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

    __overlay_rebuild
}

__overlay_rebuild() {
    load_u-boot_setting

    for i in "$U_BOOT_FDT_OVERLAYS_DIR"/*.dtbo
    do
        :
    done
    u-boot-update
    echo "Rebuilding boot configuration completed."
    read -rp "Press enter to continue..."
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
"Detected 'U_BOOT_FDT_OVERLAYS' in '$ROOT_PATH/etc/default/u-boot'.
This usually happens when you want to customize your boot process.
To avoid potential conflicts, overlay feature is temporarily disabled until such customization is reverted."
        return
    fi

    menu_init
    menu_add __overlay_install "Install overlay from source"
    menu_add __overlay_manage "Manage installed overlay"
    menu_add __overlay_rebuild "Rebuild boot configuration"
    menu_add __overlay_reset "Reset overlay libraries with kernel's default"
    menu_show "Configure Device Tree Overlay"
}
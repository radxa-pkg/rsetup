# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/mod/get_setup_script.sh
source "/usr/lib/rsetup/mod/get_setup_script.sh"

__system_system_update() {
    if yesno "System will be updated, continue?"
    then
        if ! system_update; then
            cat <<EOF
==================
Update has failed.
This may be caused by network issue, or clock out of sync.
You can try update again later.
EOF
        fi
        read -rp "Press enter to continue..."
    fi
}

__system_select_compatible_bootloader() {
    __parameter_count_check 1 "$@"

    radiolist_init

    local products i p title="$1"
    mapfile -t products < <(get_product_ids)
    for i in /usr/lib/{u-boot,edk2/*}/*
    do
        i="$(basename "$i")"

        for p in "${products[@]}"
        do
            if [[ "$(sed -E "s/[-_]//g" <<< "$i")" == "$(sed -E "s/[-_]//g" <<< "$p")" ]] || \
               [[ "$(sed -E "s/[-_]//g" <<< "$i")" == "$(sed -E "s/[-_]//g" <<< "$p-spi")" ]]
            then
                radiolist_add "$i" "OFF"
                break
            fi
        done
    done
    radiolist_emptymsg "No compatible bootloader is available."

    if ! radiolist_show "$title" || radiolist_is_selection_empty
    then
        return 1
    fi

    radiolist_getitem "${RTUI_RADIOLIST_STATE_NEW[0]}"
}

__system_bootloader_helper() {
    local bootloader_type="$1" bootloader_method="$2" warning_message="$3"

    if ! yesno "$warning_message"
    then
        return
    fi

    local bootloader title

    if [[ "$bootloader_method" == "erase_"* ]]
    then
        title="Please select the bootloader to be erased:"
    else
        title="Please select the bootloader to be installed:"
    fi

    if ! bootloader="$(__system_select_compatible_bootloader "$title")"
    then
        return
    fi

    local setup_script

    if ! setup_script="$(get_setup_script "$bootloader")"; then
        msgbox "The setup script does not exist, please check your installation."
        return
    fi

    if __external_script_type_check "$setup_script" "$bootloader_method" "function" && \
        "$bootloader_method" "$bootloader"
    then
        msgbox "The $bootloader_type has been updated successfully."
    else
        ret=$?
        case "$(( ret - 256 ))" in
            "$ERROR_ILLEGAL_PARAMETERS")
                msgbox "This product does not support the current operation for the selected $bootloader_type."
                ;;
            "$ERROR_REQUIRE_FILE")
                msgbox "The selected $bootloader_type is missing important components.

Please reinstall the $bootloader_type and try again."
                ;;
            "$ERROR_REQUIRE_TARGET")
                msgbox "The installation destination for the selected $bootloader_type does not exist.

Please check if related overlay is enabled, and the targetting device is connected."
                ;;
            *)
                msgbox "The updating process has failed. System might be broken!"
                ;;
        esac
    fi
}

__system_update_bootloader() {
    __system_bootloader_helper "bootloader" update_bootloader \
"Updating bootloader is not necessary in most cases.
Incorrect bootloader can make system unbootable.

Are you sure you want to update the bootloader?"
}

__system_update_spinor() {
    __system_bootloader_helper "SPI bootloader" update_spinor \
"Updating bootloader is not necessary in most cases.
Incorrect bootloader can make system unbootable.

In addition, SPI bootloader is stored on non-removable storage, and it is harder
to recover from a failed state.

You should only use this option when you are confident to recover a corrupted
SPI bootloader, or have flashed on-board SPI flash manually before.

Are you sure you want to update the bootloader?"
}

__system_update_emmc_boot() {
    __system_bootloader_helper "eMMC Boot partition bootloader" update_emmc_boot \
"Updating bootloader is not necessary in most cases.
Incorrect bootloader can make system unbootable.

In addition, eMMC Boot partition could be on the non-removable storage, and it is
harder to recover from a failed state.

You should only use this option when you are confident to recover a corrupted
eMMC Boot partition, or have flashed on-board eMMC Boot partition manually before.

Are you sure you want to update the bootloader?"
}

__system_erase_spinor() {
    __system_bootloader_helper "SPI bootloader" erase_spinor \
"Erasing bootloader can make system unbootable.

If you are running the system off a NVMe drive, you likely requires this bootloader
to be installed.

If your previous installation of the bootloader failed, you can use this option
to remove it, and preventing the system into unbootable state due to bad bootloader.
You still need a valid bootloader on another location for the system to work.

Are you sure you want to erase the bootloader?"
}

__system_erase_emmc_boot() {
    __system_bootloader_helper "eMMC Boot partition bootloader" erase_emmc_boot \
"Erasing bootloader can make system unbootable.

If you are running the system off a NVMe drive, you likely requires this bootloader
to be installed.

If your previous installation of the bootloader failed, you can use this option
to remove it, and preventing the system into unbootable state due to bad bootloader.
You still need a valid bootloader on another location for the system to work.

Are you sure you want to erase the bootloader?"
}

__system_set_target(){
    radiolist_init

    local current_target available_targets i new_target
    current_target="$(systemctl get-default)"
    available_targets=(multi-user.target graphical.target)

    for i in "${available_targets[@]}"
    do
        if [[ -z "$(systemctl list-units --all --no-legend "$i")" ]]
        then
            continue
        elif [[ "$i" == "$current_target" ]]
        then
            radiolist_add "$i" "ON"
        else
            radiolist_add "$i" "OFF"
        fi
    done
    radiolist_emptymsg "No target is available."

    if ! radiolist_show "Please select the default boot target:

For CLI system, please choose 'multi-user.target'.
For desktop system, please choose 'graphical.target'." || radiolist_is_selection_empty
    then
        return
    fi

    new_target="$(radiolist_getitem "${RTUI_RADIOLIST_STATE_NEW[0]}")"

    if systemctl set-default "$new_target"
    then
        msgbox "The default target has been set to '$new_target'."
        return
    else
        msgbox "Failed to set the default target to '$new_target'." "$RTUI_PALETTE_ERROR"
        return 1
    fi
}

__system_bootloader_menu() {
    menu_init
    menu_add __system_update_bootloader "Update Bootloader"
    menu_add __system_update_spinor "Update SPI Bootloader"
    menu_add __system_update_emmc_boot "Update eMMC Boot partition"
    menu_add_separator
    menu_add __system_erase_spinor "Erase SPI Bootloader"
    menu_add __system_erase_emmc_boot "Erase eMMC Boot partition"
    menu_show "System Maintenance"
}

__system() {
    menu_init
    menu_add __system_system_update "System Update"
    menu_add __system_set_target "Change default boot target"
    menu_add_separator
    menu_add __system_bootloader_menu "Bootloader Management"
    menu_show "System"
}

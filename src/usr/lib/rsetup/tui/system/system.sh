# shellcheck shell=bash

__system_system_update() {
    echo -e "\n======================="
    if ! apt-get update
    then
        msgbox "Unable to update package list."
        return
    fi
    if ! apt-get dist-upgrade --allow-downgrades
    then
        msgbox "Unable to upgrade packages."
        return
    fi
    if ! apt-get dist-upgrade --allow-downgrades
    then
        msgbox "Unable to upgrade pinned packages."
        return
    fi
    read -rp "Press enter to continue..."
}

__system_select_compatible_bootloader() {
    radiolist_init

    local products i p
    mapfile -t products < <(get_product_ids)
    for i in /usr/lib/u-boot/*
    do
        i="$(basename "$i")"

        for p in "${products[@]}"
        do
            if [[ "$(sed -E "s/[-_]//g" <<< "$i")" == "$(sed -E "s/[-_]//g" <<< "$p")" ]]
            then
                radiolist_add "$i" "OFF"
            fi
        done
    done
    radiolist_emptymsg "No compatible bootloader is available."

    if ! radiolist_show "Please select the bootloader to be installed:" || (( ${#RSETUP_RADIOLIST_STATE_NEW[@]} == 0 ))
    then
        return 1
    fi

    radiolist_getitem "${RSETUP_RADIOLIST_STATE_NEW[0]}"
}

__system_bootloader_helper() {
    local bootloader_type="$1" bootloader_method="$2" warning_message="$3"

    if ! yesno "$warning_message"
    then
        return
    fi

    local bootloader
    if ! bootloader="$(__system_select_compatible_bootloader)"
    then
        return
    fi

    if "$bootloader_method" "$bootloader"
    then
        msgbox "The $bootloader_type has been updated successfully."
    else
        ret=$?
        case "$ret" in
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

__system() {
    menu_init
    menu_add __system_system_update "System Update"
    menu_add __system_update_bootloader "Update Bootloader"
    menu_add __system_update_spinor "Update SPI Bootloader"
    menu_add __system_update_emmc_boot "Update eMMC Boot partition"
    menu_show "System Maintenance"
}

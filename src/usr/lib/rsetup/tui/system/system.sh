# shellcheck shell=bash

__system_system_update() {
    echo -e "\n======================="
    if ! apt-get update
    then
        msgbox "Unable to update package list."
        return
    fi
    if ! apt-get full-upgrade
    then
        msgbox "Unable to upgrade packages."
        return
    fi
    read -rp "Press enter to continue..."
}

__system_update_bootloader() {
    if ! yesno "Updating bootloader is not necessary in most cases.
Incorrect bootloader can make system unbootable.

Are you sure you want to update the bootloader?"
    then
        return
    fi

    radiolist_init

    local pid
    pid="$(get_product_id)"
    for i in /usr/lib/u-boot-"$pid"*
    do
        radiolist_add "${i##/usr/lib/u-boot-}" "OFF"
    done
    radiolist_emptymsg "No compatible bootloader is available."

    if ! radiolist_show "Please select the bootloader to be installed:" || (( ${#RSETUP_RADIOLIST_STATE_NEW[@]} == 0 ))
    then
        return
    fi

    if update_bootloader "$(radiolist_getitem "${RSETUP_RADIOLIST_STATE_NEW[0]}")"
    then
        msgbox "The bootloader has been updated successfully."
    else
        msgbox "The updating process has failed. System might be broken!"
    fi
}

__system() {
    menu_init
    menu_add __system_system_update "System Update"
    menu_add __system_update_bootloader "Update Bootloader"
    menu_show "System Maintaince"
}
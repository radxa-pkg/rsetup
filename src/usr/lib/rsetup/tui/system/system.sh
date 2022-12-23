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

    if update_bootloader
    then
        msgbox "The bootloader has been successfully updated."
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
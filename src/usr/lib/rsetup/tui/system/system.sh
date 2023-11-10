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

    local pid
    pid="$(get_product_id)"
    for i in /usr/lib/u-boot/*
    do
        i="$(basename "$i")"

        if [[ "$(sed -E "s/[-_]//g" <<< "$i")" == "$(sed -E "s/[-_]//g" <<< "$pid")" ]]
        then
            radiolist_add "$i" "OFF"
        fi
    done
    radiolist_emptymsg "No compatible bootloader is available."

    if ! radiolist_show "Please select the bootloader to be installed:" || (( ${#RSETUP_RADIOLIST_STATE_NEW[@]} == 0 ))
    then
        return 1
    fi

    radiolist_getitem "${RSETUP_RADIOLIST_STATE_NEW[0]}"
}

__system_update_bootloader() {
    if ! yesno "Updating bootloader is not necessary in most cases.
Incorrect bootloader can make system unbootable.

Are you sure you want to update the bootloader?"
    then
        return
    fi

    local bootloader
    if ! bootloader="$(__system_select_compatible_bootloader)"
    then
        return
    fi

    if update_bootloader "$bootloader"
    then
        msgbox "The bootloader has been updated successfully."
    else
        ret=$?
        case $ret in
            100)
                msgbox "The selected bootloader does not support installing on the boot media."
                ;;
            *)
                msgbox "The updating process has failed. System might be broken!"
                ;;
        esac
    fi
}

__system_update_spinor() {
    if ! yesno "Updating bootloader is not necessary in most cases.
Incorrect bootloader can make system unbootable.

In addition, SPI bootloader is stored on non-removable storage, and it is harder
to recover from a failed state.

You should only use this option when you are confident to recover a corrupted
SPI bootloader, or have flashed on-board SPI flash manually before.

Are you sure you want to update the bootloader?"
    then
        return
    fi

    local bootloader
    if ! bootloader="$(__system_select_compatible_bootloader)"
    then
        return
    fi

    if update_spinor "$bootloader"
    then
        msgbox "The bootloader has been updated successfully."
    else
        ret=$?
        case $ret in
            100)
                msgbox "The selected bootloader does not support SPI boot."
                ;;
            *)
                msgbox "The updating process has failed. System might be broken!"
                ;;
        esac
    fi
}

__system_update_emmc_boot() {
    if ! yesno "Updating bootloader is not necessary in most cases.
Incorrect bootloader can make system unbootable.

In addition, eMMC Boot partition could be on the non-removable storage, and it is
harder to recover from a failed state.

You should only use this option when you are confident to recover a corrupted
eMMC Boot partition, or have flashed on-board eMMC Boot partition manually before.

Are you sure you want to update the bootloader?"
    then
        return
    fi

    local bootloader
    if ! bootloader="$(__system_select_compatible_bootloader)"
    then
        return
    fi

    if update_emmc_boot "$bootloader"
    then
        msgbox "The bootloader has been updated successfully."
    else
        ret=$?
        case $ret in
            100)
                msgbox "The selected bootloader does not support booting from eMMC Boot partition."
                ;;
            *)
                msgbox "The updating process has failed. System might be broken!"
                ;;
        esac
    fi
}

__system() {
    menu_init
    menu_add __system_system_update "System Update"
    menu_add __system_update_bootloader "Update Bootloader"
    menu_add __system_update_spinor "Update SPI Bootloader"
    menu_add __system_update_emmc_boot "Update eMMC Boot partition"
    menu_show "System Maintenance"
}

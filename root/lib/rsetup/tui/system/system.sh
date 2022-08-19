__system_system_update() { 
    apt update
    apt full-upgrade
    read -p "Press enter to continue..."
}

__system_update_bootloader() {
    local cur_board_name="$(dtname)"
    local root_dev="$(__get_root_dev)"
    local mapped_board_name="$(echo "$cur_board_name" | tr , -)"
    "$ROOT_PATH/lib/rsetup/cli/system.sh" update_bootloader $mapped_board_name
    if (( $? == 0 ))
    then
        msgbox "The bootloader has been successfully updated."
    else
        msgbox "The updating process has failed."
    fi
}

__system() {
    menu_init
    menu_add __system_system_update "System Update" 
    menu_add __system_update_bootloader "Update Bootloader"
    menu_show "System Maintaince"
}
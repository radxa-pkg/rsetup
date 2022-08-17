__system_system_update() { 
    sudo apt update && sudo apt full-upgrade
}

__system_update_bootloader() {
    local cur_board_name="$(dtname)"
    local root_dev="$(__get_root_dev)"
    local mapped_board_name="$(echo "$cur_board_name" | tr , -)"
    "$ROOT_PATH/lib/rsetup/cli/system.sh" update_bootloader $mapped_board_name
}

__system() {
    menu_init
    menu_add __system_system_update "System Update" 
    menu_add __system_update_bootloader "Update Bootloader"
    menu_show "System Maintaince"
}
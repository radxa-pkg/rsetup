__system_system_update() { 
    menu_init
    menu_add __tui_about "About"
    menu_show "Update System"

    # sudo apt update && sudo apt full-upgrade
}

__system_update_bootloader() {
    menu_init
    menu_add __tui_about "About"
    menu_show "Update Bootloader"

    # # get curent board name
    # dtname=output(uname -r)
    # #get root dev
    # arr=($(stat / |grep Device))
    # root_dev=${arr[1]}

    # # dtname-board name mapping

    # # upload boot loader
    # "$ROOT_PATH/lib/rsetup/cli/main.sh" update_bootloader
}

__system() {
    menu_init
    menu_add __system_system_update "System Update" 
    menu_add __system_update_bootloader "Update Bootloader"
    menu_show "System Maintaince"
}
#!/bin/bash

source "$ROOT_PATH/lib/rsetup/mod/tui.sh"

source "$ROOT_PATH/lib/rsetup/tui/overlay/overlay.sh"
source "$ROOT_PATH/lib/rsetup/tui/comm/comm.sh"
source "$ROOT_PATH/lib/rsetup/tui/hardware/hardware.sh"
source "$ROOT_PATH/lib/rsetup/tui/local/local.sh"
source "$ROOT_PATH/lib/rsetup/tui/system/system.sh"
source "$ROOT_PATH/lib/rsetup/tui/task/task.sh"
source "$ROOT_PATH/lib/rsetup/tui/user/user.sh"

if [[ "$DEBUG" == "1" ]]
then
    source "$ROOT_PATH/lib/rsetup/tui/test/test.sh"
fi

__tui_about() {
    msgbox "rsetup - Radxa system setup utility\n\nCopyright 2022-$(date +%Y) Radxa Computer Co., Ltd"
}

__tui_main() {
    menu_init
    menu_add __system "System Maintaince"
    menu_add __hardware "Onboard Functions"
    menu_add __overlay "Overlay Management"
    menu_add __comm "Connectivity"
    menu_add __user "User Settings"
    menu_add __local "Localization"
    menu_add __task "Common Tasks"
    if [[ "$DEBUG" == "1" ]]
    then
        menu_add __test "TUI Test"
    fi
    menu_add __tui_about "About"
    menu_show "Please select an option below:"
}
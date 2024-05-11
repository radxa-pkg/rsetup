# shellcheck shell=bash


# shellcheck source=externals/librtui/src/lib/librtui/tui.sh
source "/usr/lib/librtui/tui.sh"

# shellcheck source=src/usr/lib/rsetup/tui/overlay/overlay.sh
source "/usr/lib/rsetup/tui/overlay/overlay.sh"
# shellcheck source=src/usr/lib/rsetup/tui/comm/comm.sh
source "/usr/lib/rsetup/tui/comm/comm.sh"
# shellcheck source=src/usr/lib/rsetup/tui/hardware/hardware.sh
source "/usr/lib/rsetup/tui/hardware/hardware.sh"
# shellcheck source=src/usr/lib/rsetup/tui/local/local.sh
source "/usr/lib/rsetup/tui/local/local.sh"
# shellcheck source=src/usr/lib/rsetup/tui/system/system.sh
source "/usr/lib/rsetup/tui/system/system.sh"
# shellcheck source=src/usr/lib/rsetup/tui/task/task.sh
source "/usr/lib/rsetup/tui/task/task.sh"
# shellcheck source=src/usr/lib/rsetup/tui/user/user.sh
source "/usr/lib/rsetup/tui/user/user.sh"

__tui_about() {
    msgbox "rsetup - Radxa system setup utility

Copyright 2022-$(date +%Y) Radxa Computer Co., Ltd"
}

__tui_main() {
    menu_init
    menu_add __system "System Maintenance"
    menu_add __hardware "Hardware"
    menu_add __overlay "Overlays"
    menu_add __comm "Connectivity"
    menu_add __user "User Settings"
    menu_add __local "Localization"
    if $DEBUG
    then
        menu_add __task "Common Tasks"
    fi
    menu_add __tui_about "About"
    menu_show "Please select an option below:"
}

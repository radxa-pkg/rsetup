# shellcheck shell=bash

__task_steam_uninstall() {
    if yesno "Are you sure to uninstall Steam?"
    then
        if uninstall_steam
        then
            msgbox "Steam was successfully uninstalled."
        else
            msgbox "Failed to uninstall steam." "$RTUI_PALETTE_ERROR"
        fi
    fi
}

__task_steam_install() {
    if lsmod | grep -q panthor; then
        text="Are you sure you want to install Steam?"
    else
        text="You are using a device that has an incompatible gpu, you may experience stutters or crashes, do you still want to install Steam?"
    fi
    if yesno "$text"
    then
        install_steam
    fi
}

__task_steam() {
    menu_init
    # "$(get_user_home)/steam" exists
    if [[ -d "$(get_user_home)/steam" ]]
    then
        menu_add __task_steam_uninstall   "Uninstall Steam"
    else
        menu_add __task_steam_install     "Install Steam"
    fi
    menu_show "Please select an option below:"
}

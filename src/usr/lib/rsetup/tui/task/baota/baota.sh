# shellcheck shell=bash

__task_baota_uninstall() {
    if yesno "Are you sure to uninstall Baota?"
    then
        if uninstall_baota
        then
            msgbox "Baota was successfully uninstalled."
        else
            msgbox "Failed to uninstall Baota." "$RTUI_PALETTE_ERROR"
        fi
    fi
}

__task_baota_install() {
    if yesno "Are you sure you want to install Baota?"
    then
        install_baota
    fi
}

__task_baota() {
    menu_init
    if [[ -f /www/server/panel/BT-Panel ]]
    then
        menu_add __task_baota_uninstall   "Uninstall Baota"
    else
        menu_add __task_baota_install     "Install Baota"
    fi
    menu_show "Please select an option below:"
}

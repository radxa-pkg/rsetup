__task_docker_uninstall() {
    if yesno "Are you sure to uninstall Docker?"
    then
        if uninstall_docker
        then
            msgbox "Uninstall Docker success."
        else
            msgbox "Uninstall Docker failure."
        fi
    fi
}

__task_docker_install() {
    if yesno "Are you sure to install Docker?"
    then
        install_docker
    fi
}

__task_docker_enable() {
    if yesno "Are you sure to enable Docker?"
    then
        if enable_docker
        then
            msgbox "Enable Docker success."
        else
            msgbox "Enable Docker failure."
        fi
    fi
}

__task_docker_disable() {
    if yesno "Are you sure to enable Docker?"
    then
        if disable_docker
        then
            msgbox "Disable Docker success."
        else
            msgbox "Disable Docker failure."
        fi
    fi
}

__task_docker() {
    menu_init
    if apt list --installed docker.io | grep docker.io
    then
        menu_add __task_docker_uninstall   "Uninstall Docker" 
    else 
        menu_add __task_docker_install     "Install Docker"
    fi
    
    local cur_status
    cur_status=$(systemctl status docker | grep Loaded | awk '{print $4}')
    if [[ "$cur_status" == "enabled;" ]]
    then
        menu_add __task_docker_disable    "Disable Docker"
    elif [[ "$cur_status" == "disabled;" ]]
    then
        menu_add __task_docker_enable     "Enable Docker"
    fi
    menu_show "Please select an option below:"
}

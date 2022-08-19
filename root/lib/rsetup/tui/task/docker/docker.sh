__task_docker_uninstall() {
    local item
    item=$(yesno "Are you sure to uninstall Docker?")
    if [[ $? == 0 ]]
    then
        uninstall_docker
        if [[ $? == 0 ]]
        then
            msgbox "Uninstall Docker success."
        else
            msgbox "Uninstall Docker failure."
        fi    
    fi
}

__task_docker_install() {
    local item
    item=$(yesno "Are you sure to install Docker?")
    if [[ $? == 0 ]]
    then
        install_docker
    fi
}

__task_docker_enable() {
    local item
    item=$(yesno "Are you sure to enable Docker?")
    if [[ $? == 0 ]]
    then
        enable_docker
        if [[ $? == 0 ]]
        then
            msgbox "Enable Docker success."
        else
            msgbox "Enable Docker failure."    
        fi 
    fi
}

__task_docker_disable() {
    local item
    item=$(yesno "Are you sure to disable Docker?")
    if [[ $? == 0 ]]
    then
        disable_docker
        if [[ $? == 0 ]]
        then
            msgbox "Disable Docker success."
        else
            msgbox "Disable Docker failure."    
        fi 
    fi
}

__task_docker() {
    menu_init
    local cur_ver
    cur_ver=$(docker version)
    if [[ $? == 0 ]]
    then
        menu_add __task_docker_uninstall   "Uninstall Docker" 
    else 
        menu_add __task_docker_install     "Install Docker"
    fi 
    
    local cur_status
    cur_status=$(systemctl status docker | grep Active: | awk '{print $3}')
    if [[ "$cur_status" == "(running)" ]]
    then
        menu_add __task_docker_disable    "Disable Docker"      
    elif [[ "$cur_status" != "" ]]
    then
        menu_add __task_docker_enable     "Enable Docker"        
    fi
    menu_show "Please select an option below:"
}

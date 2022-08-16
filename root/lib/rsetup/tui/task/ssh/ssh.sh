__task_ssh_uninstall() {
    local item
    item=$(yesno "Are you sure to uninstall SSH service?")
    if [[ $? == 0 ]]
    then
        uninstall_ssh
        msgbox "Uninstall SSH success."
    fi     
}

__task_ssh_install() {   
    local item
    item=$(yesno "Are you sure to install SSH service?")
    if [[ $? == 0 ]]
    then
        install_ssh
        item=$(ssh localhost)
        if [[ $? == 0 ]]
        then
            msgbox "Install SSH success."
        else
            msgbox "Install SSH failure."
        fi
    fi    
}

__task_ssh_enable() {
    local item
    item=$(yesno "Would you like the SSH server to be enabled?\nCaution: Default and weak passwords are a security risk when SSH is enabled!")
    if [[ $? == 0 ]]
    then
        enable_ssh  
        if [[ $? == 0 ]]
        then
            msgbox "Enable SSH success."
        else
            msgbox "Enable SSH failure."    
        fi 
    fi    
}

__task_ssh_disable() {
    local item
    item=$(yesno "Would you like the SSH server to be disabled?")
    if [[ $? == 0 ]]
    then
        disable_ssh
        if [[ $? == 0 ]]
        then
            msgbox "Disable SSH success."
        else
            msgbox "Disable SSH failure."    
        fi 
    fi    
}

__task_ssh() {
    menu_init
    local status            
    status=$(systemctl status ssh  | awk 'NR==1 {print $4}')
    if [[ "$status" == "OpenBSD" ]]
    then
        menu_add __task_ssh_uninstall   "Uninstall SSH"
    else
        menu_add __task_ssh_install     "Install SSH"
    fi

    status=$(systemctl status ssh | grep Active | awk '{print $3}')
    if [[ "$status" == "(running)" ]]
    then
        menu_add __task_ssh_disable     "Disable SSH"
    elif [[ "$status" == "(dead)" ]]
    then
        menu_add __task_ssh_enable      "Enable SSH"
    fi       
    menu_show "Please select an option below:"
}

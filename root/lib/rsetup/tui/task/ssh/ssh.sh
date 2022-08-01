__task_ssh_install(){
    msgbox "SSH: Install/Uninstall now." 
}

__task_ssh_enable(){
    msgbox "SSH: Enable/Disable now." 
}

__task_ssh(){
    menu_init
    menu_add __task_ssh_install   "Install/Uninstall now"
    menu_add __task_ssh_enable    "Enable/Disable now"
    menu_show "Please select an option below:"
}

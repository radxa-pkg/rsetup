__task_docker_install(){
    msgbox "Docker: Install/Uninstall now." 
    unregister_screen   
}

__task_docker_enable(){
    msgbox "Docker: Enable/Disable now." 
    unregister_screen       
}

__task_docker(){
    menu_init
    menu_add __task_docker_install   "Install/Uninstall now"
    menu_add __task_docker_enable    "Enable/Disable now"
    menu_show "Please select an option below:"
}

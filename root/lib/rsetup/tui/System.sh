#!/bin/bash
__main_System(){
    menu_init
    menu_add __System_Systemupdate "System update" 
    menu_add __System_Updatebootloader "Update bootloader"
}

__System_Systemupdate(){
    sudo apt update && sudo apt full-upgrade
}
__System_Updatebootloader(){
    menu_init
}
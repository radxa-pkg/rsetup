#! /bin/bash

software_network_ip_check(){
    
    IP=$(ifconfig | grep netmask  | cut -d " " -f 10 | grep ^19)
    if [ $? = 0 ]
    then
        msgbox "IP:$IP"
    else
        msgbox "Failed to View IP address!"
    fi

    unregister_screen
}

software_network_ip_seltct(){
    
    msgbox "Select dynamic or edit static IP address."

    unregister_screen 
}

software_network_ip_control(){
    
    msgbox "Disable IPv6 for APT and system."

    unregister_screen 
}



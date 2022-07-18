#! /bin/bash


software_interface_peripheral() {
    checklist_init
    checklist_add "PWM0"  "OFF"
    checklist_add "PWM1"  "ON"
    checklist_add "UART2" "OFF"
    checklist_add "UART4" "OFF"
    checklist_add "SPI1"  "OFF"
    checklist_add "SPI2"  "OFF"
    checklist_add "I2C2"  "OFF"
    checklist_add "I2C6"  "OFF"
    checklist_add "I2C7"  "OFF"
    checklist_show "Turn on or off peripherals"
    if [ $? = 0 ]
    then
        msgbox "Offered '${RSETUP_CHECKLIST_STATE_OLD[*]}', selected '${RSETUP_CHECKLIST_STATE_NEW[*]}'."
    else
        msgbox "User cancelled action."
    fi

    unregister_screen
}


software_interface_ssh() {
    radiolist_init
    radiolist_add "1 SSH key login"                 "OFF"
    radiolist_add "2 Password login"                "ON"
    radiolist_add "3 Allow root login"              "OFF"
    radiolist_add "4 Phone Authentication login"    "OFF"
    
    radiolist_show "Select a login mode"
    if [ $? = 0 ]
    then
        #msgbox "Offered '${RSETUP_RADIOLIST_STATE_OLD[*]}', selected '${RSETUP_RADIOLIST_STATE_NEW[*]}'."
        case ${RSETUP_RADIOLIST_STATE_NEW[*]} in
            0)
                msgbox "SSH Key login"
            ;;
            1)
                msgbox "Password login"
            ;;
            2)
                msgbox "Allow root login"
            ;;
            3)
                msgbox "Phone Authentication login"
            ;;
            *)
                msgbox " "
            ;;
        esac
            

    #else
        #msgbox "choose what you want to enable or disable."
    fi

    unregister_screen
}
#!/bin/bash

__main_test_yesno() {
    local ITEM
    ITEM=$(yesno "Yes, or No?")
    if [ $? = 0 ]
    then
        msgbox "User selected yes."
    else
        msgbox "User selected no."
    fi

    unregister_screen
}

__main_test_msgbox() {
    msgbox "A msgbox."

    unregister_screen
}

__main_test_inputbox() {
    local ITEM
    ITEM=$(inputbox "Say something." "Like this.")
    if [ $? = 0 ]
    then
        msgbox "User said '$ITEM'."
    else
        msgbox "User cancelled action."
    fi

    unregister_screen
}

__main_test_passwordbox() {
    local ITEM
    ITEM=$(passwordbox "Tell me a secret.")
    if [ $? = 0 ]
    then
        msgbox "User said '$ITEM'."
    else
        msgbox "User cancelled action."
    fi

    unregister_screen
}

__main_test_gauge() {
    for i in {0..5}
    do
        echo $(( i * 20 ))
        sleep 1
    done | gauge "Let's go!" 0

    unregister_screen
}

__main_test_checklist() {
    checklist_init
    checklist_add "Item 1" "OFF"
    checklist_add "Item 2" "ON"
    checklist_add "Item 3" "OFF"
    checklist_show "Checklist"
    if [ $? = 0 ]
    then
        msgbox "Offered '${RSETUP_CHECKLIST_STATE_OLD[*]}', selected '${RSETUP_CHECKLIST_STATE_NEW[*]}'."
    else
        msgbox "User cancelled action."
    fi

    unregister_screen
}

__main_test_radiolist() {
    radiolist_init
    radiolist_add "Item 1" "OFF"
    radiolist_add "Item 2" "ON"
    radiolist_add "Item 3" "OFF"
    radiolist_show "Radiolist"
    if [ $? = 0 ]
    then
        msgbox "Offered '${RSETUP_RADIOLIST_STATE_OLD[*]}', selected '${RSETUP_RADIOLIST_STATE_NEW[*]}'."
    else
        msgbox "User cancelled action."
    fi

    unregister_screen
}

__main_test() {
    menu_init
    menu_add __main_test_yesno "yesno"
    menu_add __main_test_msgbox "msgbox"
    menu_add __main_test_inputbox "inputbox"
    menu_add __main_test_passwordbox "passwordbox"
    menu_add __main_test_gauge "gauge"
    menu_add_separator
    menu_add __main_test_checklist "checklist"
    menu_add_separator
    menu_add __main_test_radiolist "radiolist"
    menu_show "TUI tests"
}
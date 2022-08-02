__test_yesno() {
    local item
    item=$(yesno "Yes, or No?")
    if [[ $? == 0 ]]
    then
        msgbox "User selected yes."
    else
        msgbox "User selected no."
    fi
}

__test_msgbox() {
    msgbox "A msgbox."
}

__test_inputbox() {
    local item
    item=$(inputbox "Say something." "Like this.")
    if [[ $? == 0 ]]
    then
        msgbox "User said '$item'."
    else
        msgbox "User cancelled action."
    fi
}

__test_passwordbox() {
    local item
    item=$(passwordbox "Tell me a secret.")
    if [[ $? == 0 ]]
    then
        msgbox "User said '$item'."
    else
        msgbox "User cancelled action."
    fi
}

__test_gauge() {
    for i in {0..5}
    do
        echo $(( i * 20 ))
        sleep 1
    done | gauge "Let's go!" 0
}

__test_checklist() {
    checklist_init
    checklist_add "Item 1" "OFF"
    checklist_add "Item 2" "ON"
    checklist_add "Item 3" "OFF"
    checklist_show "Checklist"
    if [[ $? == 0 ]]
    then
        msgbox "Offered '${RSETUP_CHECKLIST_STATE_OLD[*]}', selected '${RSETUP_CHECKLIST_STATE_NEW[*]}'."
    else
        msgbox "User cancelled action."
    fi
}

__test_radiolist() {
    radiolist_init
    radiolist_add "Item 1" "OFF"
    radiolist_add "Item 2" "ON"
    radiolist_add "Item 3" "OFF"
    radiolist_show "Radiolist"
    if [[ $? == 0 ]]
    then
        msgbox "Offered '${RSETUP_RADIOLIST_STATE_OLD[*]}', selected '${RSETUP_RADIOLIST_STATE_NEW[*]}'."
    else
        msgbox "User cancelled action."
    fi
}

__test() {
    menu_init
    menu_add __test_yesno "yesno"
    menu_add __test_msgbox "msgbox"
    menu_add __test_inputbox "inputbox"
    menu_add __test_passwordbox "passwordbox"
    menu_add __test_gauge "gauge"
    menu_add_separator
    menu_add __test_checklist "checklist"
    menu_add_separator
    menu_add __test_radiolist "radiolist"
    menu_show "TUI tests"
}
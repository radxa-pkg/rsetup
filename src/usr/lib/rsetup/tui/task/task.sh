# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/tui/task/docker/docker.sh
source "/usr/lib/rsetup/tui/task/docker/docker.sh"
source "/usr/lib/rsetup/tui/task/ssh/ssh.sh"

__task() {
    if $DEBUG
    then
        menu_init
        menu_add __task_docker          "Docker"
        menu_add __task_ssh             "SSH"
        menu_show "Please select an option below:"
    else
        checklist_init
        source "/usr/lib/rsetup/tui/task/baota/baota.sh"

        checklist_emptymsg "Currently there is no compatible tasks available on this device."

        if ! checklist_show "Please select all tasks you want to perform:" || checklist_is_selection_empty
        then
            return
        fi

        if yesno "The following tasks will be run:

$(for i in "${RTUI_CHECKLIST_STATE_NEW[@]}"
do
        checklist_gettitle "$i"
done)

Are you sure?"
        then
            for i in "${RTUI_CHECKLIST_STATE_NEW[@]}"
            do
                "$(checklist_getitem "$i")"
            done
        fi
    fi
    # Prevent port number and key logs from being overwritten
    read -rp "Press enter to continue..."
}

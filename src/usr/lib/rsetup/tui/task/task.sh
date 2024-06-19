# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/tui/task/docker/docker.sh
source "/usr/lib/rsetup/tui/task/docker/docker.sh"
source "/usr/lib/rsetup/tui/task/ssh/ssh.sh"
source "/usr/lib/rsetup/tui/task/baota/baota.sh"

__task() {
    menu_init
    if $DEBUG
    then
        menu_add __task_docker          "Docker"
        menu_add __task_ssh             "SSH"
    fi
    menu_add __task_baota           "Baota"
    menu_show "Please select an option below:"
}

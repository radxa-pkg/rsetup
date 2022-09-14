source "$ROOT_PATH/lib/rsetup/tui/task/docker/docker.sh"
source "$ROOT_PATH/lib/rsetup/tui/task/ssh/ssh.sh"

__task() {
    menu_init
    menu_add __task_docker          "Docker"
    menu_add __task_ssh             "SSH"
    menu_show "Please select an option below:"
}
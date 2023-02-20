# shellcheck shell=bash

ALLOWED_RCONFIG_FUNC+=("regenerate_ssh_hostkey")

regenerate_ssh_hostkey() {
    echo "Removing existing SSH host keys..."
    rm -f /etc/ssh/ssh_host_* || true
    echo "Regenerating SSH host keys..."
    dpkg-reconfigure -f noninteractive openssh-server
}

install_ssh() {
    __parameter_count_check 0 "$@"
    apt-get install openssh-server
}

uninstall_ssh() {
    __parameter_count_check 0 "$@"
    apt-get remove openssh-server
}

enable_ssh() {
    __parameter_count_check 0 "$@"
    systemctl enable --now ssh
}

disable_ssh() {
    __parameter_count_check 0 "$@"
    systemctl disable --now ssh
}
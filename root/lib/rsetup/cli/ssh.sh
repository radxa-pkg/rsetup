ALLOWED_RCONFIG_FUNC+=("regenerate_ssh_hostkey")

regenerate_ssh_hostkey() {
    echo "Remove existing SSH host keys..."
    rm -f "$ROOT_PATH/etc/ssh/ssh_host_*" || true
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
    if [ -e /var/log/regen_ssh_keys.log ] && ! grep -q "^finished" /var/log/regen_ssh_keys.log
    then
        msgbox "Initial ssh key generation still running. Please wait and try again."
        return 1
    fi
    ssh-keygen -A
    update-rc.d ssh enable    
    invoke-rc.d ssh start
}

disable_ssh() {
    __parameter_count_check 0 "$@"
    update-rc.d ssh disable 
    invoke-rc.d ssh stop 
}
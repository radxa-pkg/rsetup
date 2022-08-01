source "$ROOT_PATH/lib/rsetup/mod/utils.sh"
source "$ROOT_PATH/lib/rsetup/mod/block_helpers.sh"

__first_boot() {
    __parameter_count_check 0 "$@"
    
    if ! ls /etc/ssh/ssh_host_* >/dev/null 2>&1
    then
        echo "Regenerating SSH host key..."
        dpkg-reconfigure -f noninteractive openssh-server
    fi

    echo "Self disabling..."
    systemctl disable rsetup-first-boot.service
}


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

update_bootloader() {
    __parameter_count_check 1 "$@"
    __assert_f "/usr/lib/u-boot-$1/setup.sh"

    local device=$(__get_block_dev)

    "/usr/lib/u-boot-$1/setup.sh" update_bootloader $device
}
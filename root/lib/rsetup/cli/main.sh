#!/bin/bash

source "$ROOT_PATH/lib/rsetup/mod/utils.sh"
source "$ROOT_PATH/lib/rsetup/mod/block_helpers.sh"

__first-boot() {
    __parameter_count_check 0 "$@"
    
    if ! ls /etc/ssh/ssh_host_* >/dev/null 2>&1
    then
        # Regenerate SSH host key
        dpkg-reconfigure -f noninteractive openssh-server
    fi

    local ROOT_DEV="$(__get_root_dev)"
    local FILESYSTEM="$(blkid -s TYPE -o value $ROOT_DEV)"
    local PART_ENTRY_NUMBER="$(udevadm info --query=property --name=$ROOT_DEV | grep '^ID_PART_ENTRY_NUMBER=' | cut -d'=' -f2)"
    local PART_TABLE_TYPE="$(udevadm info --query=property --name=$ROOT_DEV | grep '^ID_PART_TABLE_TYPE=' | cut -d'=' -f2)"
    local BLOCK_DEV="$(__get_block_dev)"

    # Fix GPT second partition table (should be at the end of the block device)
    if [[ $PART_TABLE_TYPE == "gpt" ]]
    then
        sgdisk -e "$BLOCK_DEV"
        partprobe
    fi

    # Resize our root partition
    cat << EOF | parted ---pretend-input-tty $BLOCK_DEV
resizepart ${PART_ENTRY_NUMBER} 
yes
100%
EOF
    partprobe
    case "$FILESYSTEM" in
        ext4)
            resize2fs $ROOT_DEV
            ;;
        btrfs)
            btrfs filesystem resize max /
            ;;
        *)
            echo Unknown filesystem. >&2
            ;;
    esac

    # Disable ourselves
    systemctl disable rsetup-first-boot.service
}

update-bootloader() {
    __parameter_count_check 1 "$@"
    __assert_f "/usr/lib/u-boot-$1/setup.sh"

    local DEVICE=$(__get_block_dev)

    "/usr/lib/u-boot-$1/setup.sh" update_bootloader $DEVICE
}
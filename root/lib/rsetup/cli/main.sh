#!/bin/bash

source "$ROOT_PATH/lib/rsetup/mod/utils.sh"
source "$ROOT_PATH/lib/rsetup/mod/block_helpers.sh"

# cloud-initramfs-growroot provides this function
# Require parted and gdisk
__resize_root() {
    echo "Fetching block device info..."
    local root_dev="$(__get_root_dev)"
    local filesystem="$(blkid -s TYPE -o value $root_dev)"
    local part_entry_number="$(udevadm info --query=property --name=$root_dev | grep '^ID_PART_ENTRY_NUMBER=' | cut -d'=' -f2)"
    local part_table_type="$(udevadm info --query=property --name=$root_dev | grep '^ID_PART_TABLE_TYPE=' | cut -d'=' -f2)"
    local block_dev="$(__get_block_dev)"

    if [[ $part_table_type == "gpt" ]]
    then
        echo "Fixinig GPT second partition table..."
        sgdisk -e "$block_dev"
        partprobe
    fi

    echo "Resizing root partition..."
    cat << EOF | parted ---pretend-input-tty $block_dev
resizepart ${part_entry_number} 
yes
100%
EOF
    partprobe

    echo "Resizing root filesystem..."
    case "$filesystem" in
        ext4)
            resize2fs $root_dev
            ;;
        btrfs)
            btrfs filesystem resize max /
            ;;
        *)
            echo "Unknown filesystem." >&2
            ;;
    esac
}

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
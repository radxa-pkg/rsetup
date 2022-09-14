#!/bin/bash

# cloud-initramfs-growroot provides this function
# Require parted and gdisk
__resize_root() {
    echo "Fetching block device info..."
    local root_dev filesystem part_entry_number part_table_type block_dev
    root_dev="$(__get_root_dev)"
    filesystem="$(blkid -s TYPE -o value "$root_dev")"
    part_entry_number="$(udevadm info --query=property "--name=$root_dev" | grep '^ID_PART_ENTRY_NUMBER=' | cut -d'=' -f2)"
    part_table_type="$(udevadm info --query=property "--name=$root_dev" | grep '^ID_PART_TABLE_TYPE=' | cut -d'=' -f2)"
    block_dev="$(__get_block_dev)"

    if [[ $part_table_type == "gpt" ]]
    then
        echo "Fixinig GPT second partition table..."
        sgdisk -e "$block_dev"
        partprobe
    fi

    echo "Resizing root partition..."
    cat << EOF | parted ---pretend-input-tty "$block_dev"
resizepart ${part_entry_number} 
yes
100%
EOF
    partprobe

    echo "Resizing root filesystem..."
    case "$filesystem" in
        ext4)
            resize2fs "$root_dev"
            ;;
        btrfs)
            btrfs filesystem resize max /
            ;;
        *)
            echo "Unknown filesystem." >&2
            ;;
    esac
}

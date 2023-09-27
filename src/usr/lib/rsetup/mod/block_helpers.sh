# shellcheck shell=bash

__get_root_dev() {
    realpath "$(findmnt --nofsroot --noheadings --output SOURCE /)"
}

__get_block_dev() {
    echo "/dev/$(udevadm info --query=path "--name=$(__get_root_dev)" | awk -F'/' '{print $(NF-1)}')"
}

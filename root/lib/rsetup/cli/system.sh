update_bootloader() {
    __parameter_count_check 1 "$@"
    __assert_f "$ROOT_PATH/usr/lib/u-boot-$1/setup.sh"

    local device=$(__get_block_dev)

    "$ROOT_PATH/usr/lib/u-boot-$1/setup.sh" update_bootloader $device
}


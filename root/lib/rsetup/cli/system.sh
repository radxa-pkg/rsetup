ALLOWED_RCONFIG_FUNC+=("regenerate_machine_id")

update_bootloader() {
    __parameter_count_check 1 "$@"
    __assert_f "$ROOT_PATH/usr/lib/u-boot-$1/setup.sh"

    local device=$(__get_block_dev)

    "$ROOT_PATH/usr/lib/u-boot-$1/setup.sh" update_bootloader $device
}

regenerate_machine_id() {
    echo "Remove existing machine ids..."
    rm -f "$ROOT_PATH/etc/machine-id" "$ROOT_PATH/var/lib/dbus/machine-id"
    echo "Regenerating machine ids..."
    dbus-uuidgen --ensure="$ROOT_PATH/etc/machine-id"
    dbus-uuidgen --ensure
}
# shellcheck shell=bash

source "/usr/lib/rsetup/mod/block_helpers.sh"
source "/usr/lib/rsetup/mod/hwid.sh"

ALLOWED_RCONFIG_FUNC+=("regenerate_machine_id" "update_hostname" "update_locale" "enable_service" "disable_service" "resize_root" "set_thermal_governor")

update_bootloader() {
    local pid
    pid="${1:-$(get_product_id)}"
    __assert_f "/usr/lib/u-boot-$pid/setup.sh"

    local device
    device=$(__get_block_dev)

    "/usr/lib/u-boot-$pid/setup.sh" update_bootloader "$device"
}

regenerate_machine_id() {
    echo "Remove existing machine ids..."
    rm -f "/etc/machine-id" "/var/lib/dbus/machine-id"
    echo "Regenerating machine ids..."
    dbus-uuidgen --ensure="/etc/machine-id"
    dbus-uuidgen --ensure
}

update_hostname() {
    __parameter_count_check 1 "$@"

    local hostname="$1"

    echo "$hostname" > "/etc/hostname"
    cat << EOF > "/etc/hosts"
127.0.0.1 localhost
127.0.1.1 $hostname

# The following lines are desirable for IPv6 capable hosts
#::1     localhost ip6-localhost ip6-loopback
#fe00::0 ip6-localnet
#ff00::0 ip6-mcastprefix
#ff02::1 ip6-allnodes
#ff02::2 ip6-allrouters
EOF
}

update_locale() {
    __parameter_count_check 1 "$@"

    local locale="$1"
    echo "locales locales/default_environment_locale select $locale" | debconf-set-selections
    echo "locales locales/locales_to_be_generated multiselect $locale UTF-8" | debconf-set-selections
    rm "/etc/locale.gen"
    dpkg-reconfigure --frontend noninteractive locales
}

enable_service() {
    __parameter_count_check 1 "$@"

    local service="$1"
    systemctl enable --now "$service"
}

disable_service() {
    __parameter_count_check 1 "$@"

    local service="$1"
    systemctl disable --now "$service"
}

resize_root() {
    local root_dev filesystem
    root_dev="$(__get_root_dev)"
    filesystem="$(blkid -s TYPE -o value "$root_dev")"

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
            return 1
            ;;
    esac
}

set_thermal_governor() {
    __parameter_count_check 1 "$@"

    local new_policy="$1"
    for i in /sys/class/thermal/thermal_zone*/policy
    do
        echo "$new_policy" > "$i"
    done
}
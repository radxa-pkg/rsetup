# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/mod/block_helpers.sh
source "/usr/lib/rsetup/mod/block_helpers.sh"
source "/usr/lib/rsetup/mod/hwid.sh"

ALLOWED_RCONFIG_FUNC+=(
    "update_generic_hostname"
    "update_hostname"
    "update_locale"
    "enable_service"
    "disable_service"
    "resize_root"
    "set_thermal_governor"
    "set_led_trigger"
    "set_led_pattern"
    "set_led_netdev"
)

system_update() {
    echo -e "\n======================="
    if ! apt-get update
    then
        echo "Unable to update package list."
        return 1
    fi
    if ! apt-get dist-upgrade --allow-downgrades
    then
        echo "Unable to upgrade packages."
        return 2
    fi
    if ! apt-get dist-upgrade --allow-downgrades
    then
        echo "Unable to upgrade pinned packages."
        return 3
    fi
}

update_bootloader() {
    local pid device
    pid="${1:-$(get_product_id)}"
    __assert_f "/usr/lib/u-boot/$pid/setup.sh"

    device="${2:-$(__get_block_dev)}"

    "/usr/lib/u-boot/$pid/setup.sh" update_bootloader "$device"
}

erase_spinor() {
    local pid
    pid="${1:-$(get_product_id)}"
    __assert_f "/usr/lib/u-boot/$pid/setup.sh"

    "/usr/lib/u-boot/$pid/setup.sh" erase_spinor
}

update_spinor() {
    local pid
    pid="${1:-$(get_product_id)}"
    __assert_f "/usr/lib/u-boot/$pid/setup.sh"

    "/usr/lib/u-boot/$pid/setup.sh" update_spinor
}

erase_emmc_boot() {
    local pid device
    pid="${1:-$(get_product_id)}"
    __assert_f "/usr/lib/u-boot/$pid/setup.sh"

    for device in /dev/mmcblk*boot0
    do
        "/usr/lib/u-boot/$pid/setup.sh" erase_emmc_boot "$device"
    done
}

update_emmc_boot() {
    local pid device
    pid="${1:-$(get_product_id)}"
    __assert_f "/usr/lib/u-boot/$pid/setup.sh"

    for device in /dev/mmcblk*boot0
    do
        "/usr/lib/u-boot/$pid/setup.sh" update_emmc_boot "$device"
    done
}

update_generic_hostname() {
    __parameter_count_at_least_check 1 "$@"

    local current_hostname
    current_hostname="$(hostname)"

    if __in_array "$current_hostname" "$@" >/dev/null
        then
            update_hostname "$(get_product_id)"
    fi
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
    if systemctl is-enabled "$service" &>/dev/null; then
        echo "Service '$service' is already enabled."
    else
        echo "Service '$service' is not enabled. Enabling and starting now."
        systemctl enable --now "$service"
    fi
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

    local new_policy="$1" i
    for i in /sys/class/thermal/thermal_zone*/policy
    do
        echo "$new_policy" > "$i"
    done
}

RBUILD_DRIVER_ROOT_PATH="/sys/bus/platform/drivers"

RBUILD_LED_GPIO_DRIVER="leds-gpio"
RBUILD_LED_PWM_DRIVER="leds_pwm"

set_led_trigger() {
    __parameter_count_check 2 "$@"

    local led="$1" trigger="$2" node
    for node in "$RBUILD_DRIVER_ROOT_PATH/$RBUILD_LED_GPIO_DRIVER"/*/leds/"$led"/trigger "$RBUILD_DRIVER_ROOT_PATH/$RBUILD_LED_PWM_DRIVER"/*/leds/"$led"/trigger
    do
        echo "$trigger" > "$node"
    done
}

set_led_pattern() {
    local led="$1" node
    shift

    set_led_trigger "$led" pattern

    for node in "$RBUILD_DRIVER_ROOT_PATH/$RBUILD_LED_GPIO_DRIVER"/*/leds/"$led"/pattern "$RBUILD_DRIVER_ROOT_PATH/$RBUILD_LED_PWM_DRIVER"/*/leds/"$led"/pattern
    do
        echo "$*" > "$node"
    done
}

set_led_netdev() {
    __parameter_count_check 2 "$@"
    local led="$1" netdev="$2"

    set_led_trigger "$led" netdev

    for node in "$RBUILD_DRIVER_ROOT_PATH/$RBUILD_LED_GPIO_DRIVER"/*/leds/"$led"; do
        echo "$netdev" > "$node/device_name"
        echo "1" > "$node/link"
        echo "1" > "$node/tx"
        echo "1" > "$node/rx"
    done
}

set_getty_autologin() {
    local user="$1" switch="$2" service="$3"
    local config_dir="/etc/systemd/system/$service.d"

    if [[ "$switch" == "ON" ]]; then
        mkdir -p "$config_dir"
        local cmd
        if grep -q "serial" <<< "$service"; then
            cmd="-/sbin/agetty -o '-p -f -- \\\\u' --autologin $user --noclear --keep-baud 1500000,115200,57600,38400,9600 %I \$TERM"
        else
            cmd="-/sbin/agetty -o '-p -f -- \\\\u' --autologin $user --noclear %I \$TERM"
        fi
        cat << EOF | tee "$config_dir/50-rsetup-autologin.conf" >/dev/null
# Auto generated by rsetup
# DO NOT MODIFY!
[Service]
ExecStart=
ExecStart=$cmd
EOF
    else
        rm -f "$config_dir/50-rsetup-autologin.conf"
    fi

    if ! systemctl daemon-reload; then
        echo "If you are running in chroot environment, where systemd is not running, then you can ignore above error." >&2
    fi
}

set_sddm_autologin() {
    local user="$1" switch="$2"
    local config_dir="/etc/sddm.conf.d"

    if [[ "$switch" == "ON" ]]; then
        mkdir -p "$config_dir"
        cat << EOF | tee "$config_dir/50-rsetup-autologin.conf" >/dev/null
# Auto generated by rsetup
# DO NOT MODIFY!
[Autologin]
User=$user
Session=plasma
EOF
    else
        rm -f "$config_dir/50-rsetup-autologin.conf"
    fi
}

set_gdm_autologin() {
    local user="$1" switch="$2"
    local config_dir="/etc/gdm3"

    if [[ ! -f $config_dir/daemon.conf ]]; then
        echo "gdm is not installed. Auto login will not be configured." >&2
        return 1
    fi

    if [[ "$switch" == "ON" ]]; then
        sed -i '/^# Rsetup/,/# Rsetup$/d' "$config_dir/daemon.conf"
        cat << EOF | tee -a "$config_dir/daemon.conf" >/dev/null
# Rsetup
# Auto generated by rsetup
# DO NOT MODIFY!
[daemon]
AutomaticLogin=$user
AutomaticLoginEnable=true
# Rsetup
EOF
    else
        sed -i '/^# Rsetup/,/# Rsetup$/d' "$config_dir/daemon.conf"
    fi
}

set_lightdm_autologin() {
    local user="$1" switch="$2"
    local config_dir="/etc/lightdm/lightdm.conf.d/"

    if [[ "$switch" == "ON" ]]; then
        mkdir -p "$config_dir"
        cat << EOF | tee -a "$config_dir/50-rsetup-autologin.conf" >/dev/null
# Auto generated by rsetup
# DO NOT MODIFY!
[Seat:*]
autologin-user=$user
autologin-user-timeout=0
EOF
    else
        rm -f "$config_dir/50-rsetup-autologin.conf"
    fi
}

get_autologin_status() {
    local service="$1"

    case "$service" in
    *getty@*.service)
        if grep -q -e "--autologin" <(grep -v '^#' "/etc/systemd/system/${service}.d/50-rsetup-autologin.conf")
        then
            echo "ON"
        else
            echo "OFF"
        fi
        ;;
    sddm.service)
        if grep -q -e "[Autologin]" -e "User=" -e "Session=plasma" <(grep -v '^#' "/etc/sddm.conf.d/50-rsetup-autologin.conf")
        then
            echo "ON"
        else
            echo "OFF"
        fi
        ;;
    gdm.service)
        if grep -q -e "AutomaticLogin=" -e "AutomaticLoginEnable=true" <(grep -v '^#' "/etc/gdm3/daemon.conf")
        then
            echo "ON"
        else
            echo "OFF"
        fi
        ;;
    lightdm.service)
        if grep -q -e "[Seat:*]" -e "autologin-user=" -e "autologin-user-timeout=0" <(grep -v '^#' "/etc/lightdm/lightdm.conf.d/50-rsetup-autologin.conf")
        then
            echo "ON"
        else
            echo "OFF"
        fi
        ;;
    esac
}

set_autologin_status() {
    local user="$1" service="$2" switch="$3"

    case "$service" in
    *getty@*.service)
        set_getty_autologin "$user" "$switch" "$service"
        ;;
    sddm.service|gdm.service|lightdm.service)
        "set_${service/.service}_autologin" "$user" "$switch"
        ;;
    *)
        echo "Invalid options: $service" >&2
        return 1
        ;;
    esac
}

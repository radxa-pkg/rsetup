# shellcheck shell=bash

get_soc_vendor() {
    case "$(cat /sys/devices/soc0/family)" in
        "Amlogic Meson")
            echo "amlogic"
            ;;
        *)
            echo "unknown"
            return 1
            ;;
    esac
}

get_product_id() {
    local pid
    pid="$(tr '[:upper:]' '[:lower:]' < /sys/devices/soc0/machine | tr ' ' -)"
    case "$pid" in
        *)
            ;;
    esac
    echo "$pid"
}
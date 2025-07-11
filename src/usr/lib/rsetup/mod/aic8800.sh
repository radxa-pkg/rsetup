# shellcheck shell=bash

__aic8800_reset() {
    __parameter_count_check 1 "$@"

    while read -r
    do
        echo "bt_test > $REPLY"

        case "$(tr -d '\r' <<< "$REPLY")"
        in
            "hci recv thread ready (nil)")
                echo "Device reset successfully."
                return
                ;;
            "dev_open fail")
                echo "Unable to open /dev/$1. Is Bluetooth already up?"
                return 1
                ;;
        esac
    done < <(stdbuf -oL timeout 2 bt_test -s uart 1500000 "/dev/$1")

    echo "Command timed out."
    return 2
}

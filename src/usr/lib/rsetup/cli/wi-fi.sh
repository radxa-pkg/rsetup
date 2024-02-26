# shellcheck shell=bash

ALLOWED_RCONFIG_FUNC+=("connect_wi-fi")

connect_wi-fi() {
    local i ssid="$1" total_retry=10
    local command=(nmcli device wifi connect "$ssid")
    case $# in
        1|2)
            nmcli radio wifi on

            if (( $# == 2 ))
            then
                command+=(password "$2")
            fi

            for ((i = 0; i < total_retry; i++))
            do
                if "${command[@]}"
                then
                    echo "Wi-Fi successfully connected to $ssid."
                    return
                else
                    echo "Failed to connect to $ssid. Retry $((i + 1)) of $total_retry." >&2
                    sleep 1
                fi
            done

            echo "Wi-Fi failed to connect to $ssid after total of $total_retry retries. Quit." >&2
            return 1
            ;;
        0|*)
            echo "Usage: ${FUNCNAME[0]} [ssid] <password>" >&2
            return 1
            ;;
    esac
}

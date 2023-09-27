# shellcheck shell=bash

ALLOWED_RCONFIG_FUNC+=("connect_wi-fi")

connect_wi-fi() {
    case $# in
        1)
            nmcli radio wifi on
            nmcli dev wifi connect "$1"
            ;;
        2)
            nmcli radio wifi on
            nmcli dev wifi connect "$1" password "$2"
            ;;
        0|*)
            echo "Usage: ${FUNCNAME[0]} [ssid] <password>" >&2
            return 1
            ;;
    esac
}

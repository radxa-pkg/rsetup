# shellcheck shell=bash

which() {
    case $1 in
        u-boot-update)
            echo "$ROOT_PATH/usr/sbin/u-boot-update"
            ;;
        *)
            command which "$@"
            ;;
    esac
}
# shellcheck shell=bash

install_baota() {
    __parameter_count_check 0 "$@"
    temp="$(mktemp)"
    wget -O "$temp" "https://download.bt.cn/install/install_lts.sh"
    bash "$temp" "ed8484bec"
    rm "$temp"
}

uninstall_baota() {
    __parameter_count_check 0 "$@"
    /etc/init.d/bt stop
    update-rc.d bt remove
    rm -f /etc/init.d/bt
    rm -rf /www/server/panel
}

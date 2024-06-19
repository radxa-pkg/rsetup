# shellcheck shell=bash

install_baota() {
    __parameter_count_check 0 "$@"
    bash < <(curl -s "https://download.bt.cn/install/install-ubuntu_6.0.sh")
}

uninstall_baota() {
    __parameter_count_check 0 "$@"
    bash < <(curl -s "https://download.bt.cn/install/bt-uninstall.sh")
}

uninstall_docker() {
    __parameter_count_check 0 "$@"
    apt-get remove docker
}

install_docker() {
    __parameter_count_check 0 "$@"
    apt-get install docker
}

enable_docker() {
    __parameter_count_check 0 "$@"  
    systemctl enable --now docker
}

disable_docker() {
    __parameter_count_check 0 "$@"    
    systemctl disable --now docker
}
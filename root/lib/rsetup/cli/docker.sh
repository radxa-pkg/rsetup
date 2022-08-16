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
    update-rc.d docker enable    
    invoke-rc.d docker start
}

disable_docker() {
    __parameter_count_check 0 "$@"    
    local result
    update-rc.d docker disable
    result=$(sudo systemctl stop docker 2>&1)
    if [[ "${result:0:8}" == "Warning:" ]]
    then
        if [[ "${result:0-13}" == "docker.socket" ]]
        then
            systemctl stop docker.socket
        fi
    fi
}
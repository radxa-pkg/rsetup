ALLOWED_RCONFIG_FUNC+=("regenerate_ssh_hostkey")

regenerate_ssh_hostkey() {
    echo "Remove existing SSH host keys..."
    rm -f "$ROOT_PATH/etc/ssh/ssh_host_*" || true
    echo "Regenerating SSH host keys..."
    dpkg-reconfigure -f noninteractive openssh-server
}

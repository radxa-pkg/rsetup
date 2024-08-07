# shellcheck shell=bash
if [[ -f /etc/init.d/bt ]]
then
    checklist_add "Uninstall Baota" "OFF" "uninstall_baota"
else
    checklist_add "Install Baota" "OFF" "install_baota"
fi

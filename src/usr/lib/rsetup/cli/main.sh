# shellcheck shell=bash

source "/usr/lib/rsetup/mod/utils.sh"

source "/usr/lib/rsetup/cli/rconfig.sh"
source "/usr/lib/rsetup/cli/ssh.sh"
source "/usr/lib/rsetup/cli/system.sh"
source "/usr/lib/rsetup/cli/account.sh"
source "/usr/lib/rsetup/cli/docker.sh"
source "/usr/lib/rsetup/cli/u-boot-menu.sh"
source "/usr/lib/rsetup/cli/wi-fi.sh"

if $DEBUG
then
    source "/usr/lib/rsetup/mod/debug_utils.sh"
fi
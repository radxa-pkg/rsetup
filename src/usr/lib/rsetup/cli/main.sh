# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/mod/utils.sh
source "/usr/lib/rsetup/mod/utils.sh"
source "/usr/lib/rsetup/mod/aic8800.sh"

source "/usr/lib/rsetup/cli/rconfig.sh"
source "/usr/lib/rsetup/cli/ssh.sh"
source "/usr/lib/rsetup/cli/system.sh"
source "/usr/lib/rsetup/cli/account.sh"
source "/usr/lib/rsetup/cli/docker.sh"
source "/usr/lib/rsetup/cli/u-boot-menu.sh"
source "/usr/lib/rsetup/cli/wi-fi.sh"
source "/usr/lib/rsetup/cli/kernel.sh"

source "/usr/lib/rsetup/cli/test/mpp.sh"
source "/usr/lib/rsetup/cli/test/stress.sh"

export PATH="$PATH:/usr/lib/rsetup/mod"

if $DEBUG
then
    source "/usr/lib/rsetup/mod/debug_utils.sh"
fi

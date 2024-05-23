# shellcheck shell=bash

# shellcheck source=externals/librtui/src/lib/librtui/utils/utils.sh
source "/usr/lib/librtui/utils/utils.sh"

# shellcheck source=src/usr/lib/rsetup/mod/aic8800.sh
source "/usr/lib/rsetup/mod/aic8800.sh"

source "/usr/lib/rsetup/cli/rconfig.sh"
source "/usr/lib/rsetup/cli/ssh.sh"
source "/usr/lib/rsetup/cli/system.sh"
source "/usr/lib/rsetup/cli/account.sh"
source "/usr/lib/rsetup/cli/docker.sh"
source "/usr/lib/rsetup/cli/u-boot-menu.sh"
source "/usr/lib/rsetup/cli/wi-fi.sh"
source "/usr/lib/rsetup/cli/kernel.sh"

source "/usr/lib/rsetup/cli/test/main.sh"

export PATH="$PATH:/usr/lib/rsetup/mod"

if $DEBUG
then
    source "/usr/lib/rsetup/mod/debug_utils.sh"
fi

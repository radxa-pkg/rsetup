# shellcheck shell=bash

source "$ROOT_PATH/usr/lib/rsetup/mod/utils.sh"
source "$ROOT_PATH/usr/lib/rsetup/mod/block_helpers.sh"

source "$ROOT_PATH/usr/lib/rsetup/cli/rconfig.sh"
source "$ROOT_PATH/usr/lib/rsetup/cli/ssh.sh"
source "$ROOT_PATH/usr/lib/rsetup/cli/system.sh"
source "$ROOT_PATH/usr/lib/rsetup/cli/account.sh"
source "$ROOT_PATH/usr/lib/rsetup/cli/docker.sh"
source "$ROOT_PATH/usr/lib/rsetup/cli/local.sh"
source "$ROOT_PATH/usr/lib/rsetup/cli/u-boot-menu.sh"
source "$ROOT_PATH/usr/lib/rsetup/cli/wi-fi.sh"

if $DEBUG
then
    source "$ROOT_PATH/usr/lib/rsetup/mod/debug_utils.sh"
fi
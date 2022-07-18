source "$ROOT_PATH/lib/rsetup/mod/dialog/basic.sh"
source "$ROOT_PATH/lib/rsetup/mod/dialog/menu.sh"
source "$ROOT_PATH/lib/rsetup/mod/dialog/checklist.sh"
source "$ROOT_PATH/lib/rsetup/mod/dialog/radiolist.sh"

RSETUP_SCREEN=()

register_screen() {
    __parameter_count_check 1 "$@"
    __parameter_type_check "$1" "function"

    RSETUP_SCREEN+=( "$1" )
}

unregister_screen() {
    __parameter_count_check 0 "$@"

    RSETUP_SCREEN=( ${RSETUP_SCREEN[@]:0:$(( ${#RSETUP_SCREEN[@]} - 1 ))} )
}
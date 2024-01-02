# shellcheck shell=bash

__aic8800_reset() {
    __parameter_count_check 1 "$@"

    while read -r
    do
        if [[ "$REPLY" == "hci recv thread ready (nil)" ]]
        then
            return
        fi
    done < <(timeout 5 bt_test -s uart 1500000 "/dev/$1")

    return 1
}

# shellcheck shell=bash

ALLOWED_RCONFIG_FUNC+=("log")

readonly ERROR_REQUIRE_PARAMETER=-1
readonly ERROR_TOO_FEW_PARAMETERS=-2
readonly ERROR_REQUIRE_FILE=-3
readonly ERROR_ILLEGAL_PARAMETERS=-4
readonly ERROR_REQUIRE_TARGET=-5

__require_parameter_check() {
    if (( $# == 0 ))
    then
        echo "Incorrect usage of ${FUNCNAME[1]} from ${FUNCNAME[2]}: ${FUNCNAME[1]} requires parameter" >&2
        return $ERROR_REQUIRE_PARAMETER
    fi
}

__parameter_count_at_least_check() {
    __require_parameter_check "$@"

    local lower=$1
    shift
    if (( $# < lower ))
    then
        echo "'${FUNCNAME[1]}' expects at least '$lower' parameters while getting $#: '$*'" >&2
        return $ERROR_TOO_FEW_PARAMETERS
    fi
}

__parameter_count_at_most_check() {
    __require_parameter_check "$@"

    local upper=$1
    shift
    if (( $# > upper ))
    then
        echo "'${FUNCNAME[1]}' expects at most '$upper' parameters while getting $#: '$*'" >&2
        return $ERROR_TOO_FEW_PARAMETERS
    fi
}

__parameter_count_range_check() {
    __require_parameter_check "$@"

    local lower=$1 upper=$2
    shift 2
    __parameter_count_at_least_check "$lower" "$@"
    __parameter_count_at_most_check "$upper" "$@"
}

__parameter_count_check() {
    __require_parameter_check "$@"

    local expected=$1
    shift
    __parameter_count_range_check "$expected" "$expected" "$@"
}

__assert_f() {
    __parameter_count_check 1 "$@"

    if [[ ! -e "$1" ]]
    then
        echo "'${FUNCNAME[1]}' requires file '$1' to work!" >&2
        return $ERROR_REQUIRE_FILE
    fi
}

__assert_t() {
    __parameter_count_check 1 "$@"

    if [[ ! -e "$1" ]]
    then
        echo "'${FUNCNAME[1]}' requires target '$1' to work!" >&2
        return $ERROR_REQUIRE_TARGET
    fi
}

__parameter_value_check() {
    __require_parameter_check "$@"

    local option=$1
    shift 1
    local options=( "$@" )
    if [[ ! "${options[*]}" == *"$option"* ]]; then
        echo "'${FUNCNAME[1]}' expects one of '${options[*]}', got '$option'" >&2
        return $ERROR_ILLEGAL_PARAMETERS
    fi
}

__parameter_type_check() {
    __parameter_count_check 2 "$@"

    if [[ $(type -t "$1") != "$2" ]]
    then
        echo "'${FUNCNAME[1]}' expects '$1' type to be '$2', but it is '$(type -t "$1")'." >&2
        return $ERROR_ILLEGAL_PARAMETERS
    fi
}

__in_array() {
    local item="$1" i=0
    shift
    while (( $# > 0 ))
    do
        if [[ "$item" == "$1" ]]
        then
            echo "$i"
            return
        fi
        i=$(( i + 1 ))
        shift
    done
    return 1
}

log() {
    printf "%s\n" "$*" >&2
}

__check_terminal() {
    local devices=( "/dev/stdin" "/dev/stdout" "/dev/stderr" ) output disable_stderr
    for i in "${devices[@]}"
    do
        disable_stderr="2>&-"
        if [[ $i == "/dev/stderr" ]]
        then
            disable_stderr=
        fi

        if output="$(eval "stty size -F '$i' $disable_stderr")"
        then
            echo "$output"
            return
        fi
    done
    echo "Unable to get terminal size!" >&2
}

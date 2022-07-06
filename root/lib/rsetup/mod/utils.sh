#!/bin/bash

ERROR_REQUIRE_PARAMETER=-1
ERROR_TOO_FEW_PARAMETERS=-2
ERROR_REQUIRE_FILE=-3
ERROR_ILLEGAL_PARAMETERS=-4

__require_parameter_check() {
    set -e
    if (( $# == 0 ))
    then
        echo "Incorrect usage of ${FUNCNAME[1]} from ${FUNCNAME[2]}: ${FUNCNAME[1]} requires parameter" >&2
        return $ERROR_REQUIRE_PARAMETER
    fi
    set +e
}

__parameter_count_check() {
    __require_parameter_check "$@"
    set -e
    
    local EXPECTED=$1
    shift 1
    if (( $# != $EXPECTED ))
    then
        echo "'${FUNCNAME[1]}' expects '$EXPECTED' parameters while getting $#: '$@'" >&2
        return $ERROR_TOO_FEW_PARAMETERS
    fi
    set +e
}

__assert_f() {
    __parameter_count_check 1 "$@"
    set -e

    if [[ ! -e "$1" ]]
    then
        echo "'${FUNCNAME[1]}' requires file '$1' to work!" >&2
        return $ERROR_REQUIRE_FILE
    fi
    set +e
}

__parameter_value_check() {
    __require_parameter_check "$@"
    set -e
    
    local OPTION=$1
    shift 1
    local OPTIONS=( "$@" )
    if [[ ! " ${OPTIONS[*]} " =~ " $OPTION " ]]; then
        echo "'${FUNCNAME[1]}' expects one of '${OPTIONS[*]}', got '$OPTION'" >&2
        return $ERROR_ILLEGAL_PARAMETERS
    fi
    set +e
}
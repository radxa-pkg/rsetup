#!/bin/bash

_parameter_count_check() {
    if (( $# == 0 ))
    then
        echo 'Incorrect usage of _parameter_count_check: _parameter_count_check expected_count "$@"'
        exit -1
    fi
    
    local expected=$1
    shift 1
    if (( $# != $expected ))
    then
        echo "${FUNCNAME[1]}" expects "$expected" arguments while getting $#: "$@"
        exit -2
    fi
}

_assert_f() {
    _parameter_count_check 1 "$@"

    if [[ ! -e "$1" ]]
    then
        echo "${FUNCNAME[1]}" requires file "$1" to work!
        exit -3
    fi
}
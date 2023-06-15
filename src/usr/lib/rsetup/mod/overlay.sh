# shellcheck shell=bash

compile_dtb() {
    local temp dts="$1" dtbo="${2:-${1%.dts}.dtbo}"
    temp="$(mktemp)"
    # shellcheck disable=SC2064
    trap "rm -f $temp" RETURN EXIT

    if ! cpp -nostdinc -undef -x assembler-with-cpp -E -I "/usr/src/linux-headers-$(uname -r)/include" -I "/usr/lib/modules/$(uname -r)/build/include" "$dts" "$temp"
    then
        return 1
    fi

    if ! dtc -q -@ -I dts -O dtb -o "$dtbo" "$temp"
    then
        return 2
    fi
}

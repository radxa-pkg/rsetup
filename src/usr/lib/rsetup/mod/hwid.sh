# shellcheck shell=bash

get_soc_vendor() {
    if [[ -n "${RSETUP_SOC_VENDOR_OVERRIDE:=}" ]] || [[ ! -f /proc/device-tree/compatible ]]
    then
        echo "$RSETUP_SOC_VENDOR_OVERRIDE"
    else
        tr $"\0" $"\n" < /proc/device-tree/compatible | tail -n 1 | cut -d "," -f 1
    fi
}

get_product_ids() {
    if [[ -n "${RSETUP_PRODUCT_ID_OVERRIDE:=}" ]] || [[ ! -f /proc/device-tree/compatible ]]
    then
        echo "$RSETUP_PRODUCT_ID_OVERRIDE"
    else
        local REPLY

        while read -r
        do
            REPLY="$(cut -d "," -f 2 <<< "$REPLY")"
            if [[ $REPLY =~ ^rock ]]
            then
                echo "$REPLY"
            else
                echo "radxa-$REPLY"
            fi
        done < <(tr $"\0" $"\n" < /proc/device-tree/compatible)
    fi
}

get_product_id() {
    local products
    mapfile -t products < <(get_product_ids)
    echo "${products[0]}"
}

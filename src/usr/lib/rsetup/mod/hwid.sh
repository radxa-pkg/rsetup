# shellcheck shell=bash

get_soc_vendor() {
    if [[ -n "${RSETUP_SOC_VENDOR_OVERRIDE:=}" ]] || [[ ! -f /proc/device-tree/compatible ]]
    then
        echo "$RSETUP_SOC_VENDOR_OVERRIDE"
    else
        tr $"\0" $"\n" < /proc/device-tree/compatible | tail -n 1 | cut -d "," -f 1
    fi
}

get_product_id() {
    if [[ -n "${RSETUP_PRODUCT_ID_OVERRIDE:=}" ]] || [[ ! -f /proc/device-tree/compatible ]]
    then
        echo "$RSETUP_PRODUCT_ID_OVERRIDE"
    else
        local model
        model="$(tr $"\0" $"\n" < /proc/device-tree/compatible | head -n 1 | cut -d "," -f 2)"
        if [[ $model =~ ^rock ]]
        then
            echo "$model"
        else
            echo "radxa-$model"
        fi
    fi
}

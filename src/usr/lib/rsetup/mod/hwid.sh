# shellcheck shell=bash

get_soc_vendor() {
    tr $"\0" $"\n" < /proc/device-tree/compatible | tail -n 1 | cut -d "," -f 1
}

get_product_id() {
    tr $"\0" $"\n" < /proc/device-tree/compatible | head -n 1 | cut -d "," -f 2
}

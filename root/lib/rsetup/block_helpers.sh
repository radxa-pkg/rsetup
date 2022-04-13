#!/bin/bash

_get_root_dev() {
    realpath $(findmnt --nofsroot --noheadings --output SOURCE /)
}

_get_block_dev() {
    echo /dev/$(udevadm info --query=path --name=$(_get_root_dev) | awk -F'/' '{print $(NF-1)}')
}
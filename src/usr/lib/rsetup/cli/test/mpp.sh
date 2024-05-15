# shellcheck shell=bash

mpp_enable_kernel_logging() {
    sudo tee /sys/module/rk_vcodec/parameters/mpp_dev_debug <<<"0x100" >/dev/null
    echo "Please check dmesg output for kernel debug output."
}

mpp_enable_logging() {
    export mpi_debug=1
    export mpp_debug=1
    export mpp_dec_debug=1
    export h264d_debug=1
    export mpp_syslog_perror=1
    export mpp_log_level=6
    export GST_DEBUG="2,*mpp*:4,*fps*:7"
    export LIBV4L_RKMPP_LOG_LEVEL=6
    export DISPLAY=":0"
}

mpp_play() {
    mpp_enable_logging
    xdg-open "$1"
}

mpp_gst_play() {
    mpp_enable_logging
    gst-play-1.0 "$1"
}

mpp_chromium() {
    mpp_enable_logging
    chromium --enable-logging --vmodule=/media/gpu=4 --v=1
}

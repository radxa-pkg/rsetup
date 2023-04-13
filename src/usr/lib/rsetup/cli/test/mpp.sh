# shellcheck shell=bash

mpp_enable_logging() {
    export mpi_debug=1
    export mpp_debug=1
    export h264d_debug=1
    export mpp_syslog_perror=1
    export mpp_log_level=6
    export DISPLAY=":0"
    export GST_DEBUG="2,*mpp*:4,*fps*:7"
}

mpp_play() {
    mpp_enable_logging
    xdg-open "$1"
}

mpp_gst_play() {
    mpp_enable_logging
    gst-play-1.0 "$1"
}

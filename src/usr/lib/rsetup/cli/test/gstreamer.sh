# shellcheck shell=bash

gst_audio_resample() {
    local sample_rate="${1:-48000}"
    gst-launch-1.0 audiotestsrc ! audioresample ! audio/x-raw, rate="$sample_rate" ! autoaudiosink
}

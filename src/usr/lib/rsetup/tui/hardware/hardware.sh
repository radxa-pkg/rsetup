# shellcheck shell=bash

# shellcheck source=src/usr/lib/rsetup/mod/config.sh
source "/usr/lib/rsetup/mod/config.sh"

# shellcheck source=src/usr/lib/rsetup/tui/hardware/gpio.sh
source "/usr/lib/rsetup/tui/hardware/gpio.sh"

__hardware_gstreamer_test_picture() {
    local temp
    temp="$(mktemp "${TEMPDIR:-/tmp}/tmp.XXXXXXXXXX.jpg")"

    if gst-launch-1.0 v4l2src "device=/dev/$RSETUP_GSTREAMER_DEVICE" io-mode=4 ! \
                      autovideoconvert ! \
                      video/x-raw,format=UYVY,width=1920,height=1080 ! \
                      jpegenc ! \
                      multifilesink "location=$temp"
    then
        msgbox "Test image is saved at $temp."
    else
        rm -f "$temp"
        msgbox "Unable to capture an image with $RSETUP_GSTREAMER_DEVICE device.
Please check if you have the required libraries installed." "$RTUI_PALETTE_ERROR"
    fi
}

__hardware_gstreamer_test_live() {
    gst-launch-1.0 v4l2src "device=/dev/$RSETUP_GSTREAMER_DEVICE" io-mode=4 ! \
                   autovideoconvert ! \
                   video/x-raw,format=NV12,width=1920,height=1080,framerate=30/1 ! \
                   xvimagesink
}

__hardware_gstreamer_test() {
    RSETUP_GSTREAMER_DEVICE="$RTUI_MENU_SELECTED"
    menu_init
    if [[ -n "${DISPLAY:-}" ]]
    then
        menu_add __hardware_gstreamer_test_live "Show live video"
    fi
    menu_add __hardware_gstreamer_test_picture "Capture a picture"
    menu_show "Please select the test case:"
}

__hardware_video() {
    menu_init
    for i in /dev/video*
    do
        menu_add __hardware_gstreamer_test "$(basename "$i")"
    done
    menu_emptymsg "No supported devices is detected.

Please make sure they are enabled first."
    menu_show "Select video capture device:"
}

__hardware_gpio_leds() {
    checklist_init

    for i in "$RBUILD_DRIVER_ROOT_PATH/$RBUILD_LED_GPIO_DRIVER"/*/leds/*
    do
        if [[ -f "$i/trigger" ]]
        then
            checklist_add "$(basename "$i") [$(sed -E "s/.*\[(.*)\].*/\1/" "$i/trigger")]" "OFF"
        fi
    done
    checklist_emptymsg "No supported devices is detected.

Please make sure they are enabled first."
    if ! checklist_show "Below are the available LEDs and their triggers.
Select any to update their trigger." || checklist_is_selection_empty
    then
        return
    fi

    local triggers
    read -r -a triggers <<< "$(sed "s/\[//;s/\]//" "$(find -L "$RBUILD_DRIVER_ROOT_PATH/$RBUILD_LED_GPIO_DRIVER" -mindepth 4 -maxdepth 4 -name 'trigger' 2> /dev/null | head -1)")"

    radiolist_init
    for i in "${triggers[@]}"
    do
        radiolist_add "$i" "OFF"
    done
    if ! radiolist_show "Please select the new trigger:" || radiolist_is_selection_empty
    then
        return
    fi

    config_transaction_start
    for i in "${RTUI_CHECKLIST_STATE_NEW[@]}"
    do
        read -r -a i <<< "$(checklist_getitem "$i")"
        remove_config set_led_trigger "${i[0]}"
        enable_config set_led_trigger "${i[0]}" "$(radiolist_getitem "${RTUI_RADIOLIST_STATE_NEW[0]}")"
    done
    config_transaction_commit

    msgbox "LED trigger has been updated."
}

__pattern_breath() {
    local rgb=() sections="2" time
    mapfile -t rgb < <(color_picker)
    if (( ${#rgb[@]} == 0 ))
    then
        return
    fi

    if ! time=$(uint_inputbox "Please enter the total cycle time in milliseconds (ms):" "5000")
    then
        return
    fi

    local sections="2"
    local time_per_section=$((time / sections))

    cat << EOF
0 $time_per_section ${rgb[0]} $time_per_section
0 $time_per_section ${rgb[1]} $time_per_section
0 $time_per_section ${rgb[2]} $time_per_section
EOF
}

__pattern_rainbow() {
    local brightness time

    if ! brightness=$(uint_inputbox "Please enter the maximum brightness:" "255")
    then
        return
    elif (( 10#$brightness < 0 )) || (( 10#$brightness > 255))
    then
        msgbox "The maximum brightness must be between 0 and 255. User entered '$brightness'."
        return
    fi

    if ! time=$(uint_inputbox "Please enter the total cycle time in milliseconds (ms):" "5000")
    then
        return
    fi

    # 2 rainbow patterns are available:
    # https://www.instructables.com/How-to-Make-Proper-Rainbow-and-Random-Colors-With-/
    if (( "${RSETUP_RAINBOW_CONSTANT_BRIGHTNESS:-1}" == 1 ))
    then
        local sections="3"
        local time_per_section=$((time / sections))
        cat << EOF
$brightness $time_per_section 0 $time_per_section 0 $time_per_section
0 $time_per_section $brightness $time_per_section 0 $time_per_section
0 $time_per_section 0 $time_per_section $brightness $time_per_section
EOF
    else
        local sections="6"
        local time_per_section=$((time / sections))
        cat << EOF
$brightness $time_per_section $brightness $time_per_section 0 $time_per_section 0 $time_per_section 0 $time_per_section $brightness $time_per_section
0 $time_per_section $brightness $time_per_section $brightness $time_per_section $brightness $time_per_section 0 $time_per_section 0 $time_per_section
0 $time_per_section 0 $time_per_section 0 $time_per_section $brightness $time_per_section $brightness $time_per_section $brightness $time_per_section
EOF
    fi
}

__pattern_solid() {
    local rgb=()
    mapfile -t rgb < <(color_picker)
    if (( ${#rgb[@]} == 0 ))
    then
        return
    fi

    cat << EOF
${rgb[0]} 0 ${rgb[0]} 0
${rgb[1]} 0 ${rgb[1]} 0
${rgb[2]} 0 ${rgb[2]} 0
EOF
}

__hardware_rgb_leds() {
    checklist_init

    local i rgb_led_name
    for i in "$RBUILD_DRIVER_ROOT_PATH/$RBUILD_LED_PWM_DRIVER"/*/leds
    do
        rgb_led_name="$(basename "$(realpath "$i/..")")"
        if [[ -d "$i/$rgb_led_name-red" ]] && [[ -d "$i/$rgb_led_name-green" ]] && [[ -d "$i/$rgb_led_name-blue" ]]
        then
            checklist_add "$rgb_led_name" "OFF"
        fi
    done
    checklist_emptymsg "No supported devices is detected.

Please make sure they are enabled first."
    if ! checklist_show "Below are the available LEDs.
Select any to update their pattern." || checklist_is_selection_empty
    then
        return
    fi

    radiolist_init
    for i in breath rainbow solid
    do
        radiolist_add "$i" "OFF"
    done
    if ! radiolist_show "Please select the new pattern:" || radiolist_is_selection_empty
    then
        return
    fi

    local patterns=()
    mapfile -t patterns < <(__pattern_"$(radiolist_getitem "${RTUI_RADIOLIST_STATE_NEW[0]}")")
    if (( ${#patterns[@]} == 0 ))
    then
        return
    fi

    config_transaction_start
    for i in "${RTUI_CHECKLIST_STATE_NEW[@]}"
    do
        read -r -a i <<< "$(checklist_getitem "$i")"
        remove_config set_led_trigger "${i[0]}-red"
        enable_config set_led_trigger "${i[0]}-red" "pattern"
        remove_config set_led_pattern "${i[0]}-red"
        enable_config set_led_pattern "${i[0]}-red" "${patterns[0]}"

        remove_config set_led_trigger "${i[0]}-green"
        enable_config set_led_trigger "${i[0]}-green" "pattern"
        remove_config set_led_pattern "${i[0]}-green"
        enable_config set_led_pattern "${i[0]}-green" "${patterns[1]}"

        remove_config set_led_trigger "${i[0]}-blue"
        enable_config set_led_trigger "${i[0]}-blue" "pattern"
        remove_config set_led_pattern "${i[0]}-blue"
        enable_config set_led_pattern "${i[0]}-blue" "${patterns[2]}"
    done
    config_transaction_commit

    msgbox "LED pattern has been updated."
}

__hardware_thermal() {
    radiolist_init

    local current_policy available_policies selected_governor
    current_policy="$(cat /sys/class/thermal/thermal_zone0/policy)"
    mapfile -t available_policies < <(sed -E -e "s/ $//g" -e "s/ /\n/g" /sys/class/thermal/thermal_zone0/available_policies)
    for i in "${available_policies[@]}"
    do
        if [[ "$i" == "$current_policy" ]]
        then
            radiolist_add "$i" "ON"
        else
            radiolist_add "$i" "OFF"
        fi
    done
    radiolist_emptymsg "No thermal governor is available."

    if ! radiolist_show "Please select the thermal governor.
Recommendation: fanless or DC fan => power_allocator | PWM fan => step_wise" || radiolist_is_selection_empty
    then
        return
    fi

    selected_governor="$(radiolist_getitem "${RTUI_RADIOLIST_STATE_NEW[0]}")"

    if [[ $selected_governor == "power_allocator" ]] && grep -q "pwm-fan" "/sys/class/thermal/cooling_device"*/type <<< ""
    then
        msgbox "power_allocator governor is incompatible with pwm_fan driver.
Please disable it and try again." "$RTUI_PALETTE_ERROR"
    elif enable_unique_config set_thermal_governor "$selected_governor"
    then
        msgbox "Thermal governor has been updated."
    else
        msgbox "Thermal governor could not be updated." "$RTUI_PALETTE_ERROR"
    fi
}

__hardware_dsi_mirror() {
    local active_monitors=() dsi_monitors=() external_monitors=()
    mapfile -t active_monitors < <(xrandr --listactivemonitors | tail -n +2 | awk '{print $4}')
    for i in "${active_monitors[@]}"
    do
        if [[ "$i" =~ "DSI" ]]
        then
            dsi_monitors+=( "$i" )
        else
            external_monitors+=( "$i" )
        fi
    done

    if ! (( ${#dsi_monitors[@]} ))
    then
        msgbox "No active DSI display is found.
Please check if the overlay is enabled, and the screen is connected and powered on."
        return
    fi

    if ! (( ${#external_monitors[@]} ))
    then
        msgbox "No external display is found.
Please check if the screen is connected and powered on."
        return
    fi

    local selected_dsi="${dsi_monitors[0]}" selected_external=( "${external_monitors[0]}" )

    if (( ${#dsi_monitors[@]} > 1 ))
    then
        radiolist_init
        for i in "${dsi_monitors[@]}"
        do
            radiolist_add "$i" "OFF"
        done
        if ! radiolist_show "Please select the DSI monitor to be mirrored:" || radiolist_is_selection_empty
        then
            return
        fi
        selected_dsi="$(radiolist_getitem "${RTUI_RADIOLIST_STATE_NEW[0]}")"
    fi

    if (( ${#external_monitors[@]} > 1 ))
    then
        checklist_init
        for i in "${external_monitors[@]}"
        do
            checklist_add "$i" "OFF"
        done
        if ! checklist_show "Please select external monitors to mirror the DSI monitor:" || checklist_is_selection_empty
        then
            return
        fi
        selected_external=()
        for i in "${RTUI_CHECKLIST_STATE_NEW[@]}"
        do
            selected_external+=( "$(checklist_getitem "$i")" )
        done
    fi

    local dsi_res dsi_native_res_x dsi_native_res_y
    dsi_res="$(tail -n 1 "/sys/devices/platform/display-subsystem/drm/card*/card*-$selected_dsi/modes")"
    dsi_native_res_x="$(cut -d "x" -f 1 <<< "$dsi_res")"
    dsi_native_res_y="$(cut -d "x" -f 2 <<< "$dsi_res")"

    local xrandr_cmd=(
        xrandr
        --output "$selected_dsi"
        --auto
        --primary
    )

    if (( dsi_native_res_x < dsi_native_res_y ))
    then
        xrandr_cmd+=( --rotate left )
        dsi_res="${dsi_native_res_y}x${dsi_native_res_x}"
    fi

    for i in "${selected_external[@]}"
    do
        xrandr_cmd+=( --output "$i" )
    done
    xrandr_cmd+=(
        --auto
        --scale-from "$dsi_res"
        --same-as "$selected_dsi"
    )

    "${xrandr_cmd[@]}"

    radxa-map-tp

    msgbox "DSI display mirroring has been enabled.
To return to normal mode, please use your desktop environment's display setup tool."
}

__check_service_status() {
    local service="$1$2"
    case "$(systemctl is-enabled "$service")" in
      enabled)
          checklist_add "$service" "ON"
          ;;
      disabled)
          checklist_add "$service" "OFF"
          ;;
    esac
}

__hardware_otg() {
    checklist_init

    local udc udc_function udc_function_list services status i
    readarray -t services < <(jq -er '.[]' /usr/share/radxa-otgutils/services.json || echo -en "radxa-adbd@\nradxa-usbnet@")
    for udc in /sys/class/udc/*
    do
        udc="$(basename "$udc")"
        for i in "${services[@]}"
        do
            __check_service_status "$i" "$udc"
        done
    done

    checklist_emptymsg "No UDC exists.
You can turn on the OTG port Peripheral mode device tree overlay at rsetup and look in the /sys/class/udc directory for."

    if ! checklist_show "Below are the available UDC functions.
Select any to update their status."
    then
        return
    fi

    for i in "${RTUI_CHECKLIST_STATE_NEW[@]}"
    do
        udc_function_list+=("$(checklist_getitem "$i")")
    done
    if (( $(printf "%s\n" "${udc_function_list[@]}" | grep -o "radxa-adbd@" | wc -l) > 1 ))
    then
        msgbox "radxa-adbd can be enabled at most on one given port. Please reduce your selection and try again."
        return
    fi

    length=${#RTUI_CHECKLIST[@]}
    for ((i = 0; i < length; i+=3))
    do
        udc_function="${RTUI_CHECKLIST[i+1]}"
        status="${RTUI_CHECKLIST[i+2]}"
        if [[ "$status" == "OFF" ]]
        then
            systemctl disable --now "$udc_function"
        fi
    done
    for ((i = 0; i < length; i+=3))
    do
        udc_function="${RTUI_CHECKLIST[i+1]}"
        status="${RTUI_CHECKLIST[i+2]}"
        if [[ "$status" == "ON" ]]
        then
            systemctl enable --now "$udc_function"
        fi
    done
}

__hardware() {
    menu_init
    menu_add __hardware_video "Video capture devices"
    menu_add __hardware_gpio_leds "GPIO LEDs"
    menu_add __hardware_rgb_leds "RGB LEDs"
    menu_add __hardware_thermal "Thermal governor"
    menu_add __hardware_dsi_mirror "Configure DSI display mirroring"
    menu_add __hardware_gpio "40-pin GPIO"
    menu_add __hardware_otg "USB OTG services"
    menu_show "Manage on-board hardware"
}

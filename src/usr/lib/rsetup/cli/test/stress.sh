# shellcheck shell=bash

ALLOWED_RCONFIG_FUNC+=("factory_stress")


# Run stress-ng for factory test
#
# Test will only run when a trigger GPIO is set to
# Test status is reflected by on-board LEDs:
# LED behaviours:
#   500ms On-Off blink                          stress-ng running
#   Solid On/Off                                stress-ng failed / not running
#   Device default                              incorrect GPIO trigger pin
#
# Commands:
#   factory_stress <trigger_gpiod_name> <trigger_value>
#
# May need to manually install stress-ng first:
#   sudo apt-get update && sudo apt-get install -y stress-ng
#
factory_stress() {
    __parameter_count_check 2 "$@"
    local triggered="false" pin_name="$1" trigger_value="$2" ret="0" pin_value="-1" gpio_line=()

    read -ra gpio_line < <(gpiofind "$pin_name") || ret=$?
    pin_value="$(gpioget "${gpio_line[@]}" 2>/dev/null)" || ret=$?
    if (( ret != 0 ))
    then
        echo "Unable to find the trigger pin '$pin_name'. Quit."
        return "$ret"
    fi

    if [[ "$pin_value" == "$trigger_value" ]]
    then
        triggered="true"
    fi

    for i in "$RBUILD_DRIVER_ROOT_PATH/$RBUILD_LED_GPIO_DRIVER"/*/leds/*
    do
        if [[ -f "$i/trigger" ]]
        then
            if [[ "$triggered" == "true" ]]
            then
                set_led_trigger "$(basename "$i")" "timer"
            else
                set_led_trigger "$(basename "$i")" "none"
            fi
        fi
    done

    if [[ "$triggered" != "true" ]]
    then
        echo "Stress test triggering condition unmet. Skip."
        return
    fi

    local available_memory core_count
    available_memory=$(( $(grep MemAvailable /proc/meminfo | awk '{print $2}') / 1024 ))
    core_count="$(nproc)"

    echo "Factory stress now running in the background..."
    stress-ng --cpu $((core_count)) --vm-bytes $((available_memory * 9 / 10 / core_count))M --vm $((core_count)) --io $((core_count / 4))
}

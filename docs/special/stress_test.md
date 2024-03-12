# Stress test image

As of 0.4.1, `rsetup` can be used to create stress test images. This functionality
relies on proper `gpiod` pin definition, as well as correct GPIO LEDs device tree
definition, both are part of the system release requirements. As such, this can
be used as a unified method to create stress test images.

## `factory_stress`

This function is implemented in `factory_stress`, where the detailed command
definition can be found in the source code.

To run this command, you need to supply a GPIO pin name, which will be connected
to the GND/VCC pin during the device boot, as well as the default state when no
wire is connected.

The factory stress test procedure begins with the pin connected, which is recognized
by `factory_stress` as a signal to start the stress test, and update LEDs' pattern.
The QA engineer will then disconnect the wire once the LED pattern indicates the
test is started. This way, if the device fails the stress test and is rebooted,
`factory_stress` will not be started again due to the GPIO value does not match
the specified value.

## Prepare the image

This is generally broken into 2 stages: find the GPIO pin's default status, and
update the image.

### Find the default GPIO status

While in theory any GPIO pins can be used, we should look for pins that are easy
to identify. One such example is pin 40 where is at the end of the header, as well
as being close to a GND pin to pull down (if the default state is high).

For example, on Radxa ZERO, if we want to use pin 7, we should run following command
on ZERO:

```bash
radxa@radxa-zero:~$ gpioget $(gpiofind PIN_7)
1
```

Since the default state is 1, we will instruct the QA engineer to connect pin 7
and pin 9 (which is GND) at the start of the test.

### Update the image with stress test config

To run the stress test at the boot time, first, mount and systemd-nspawn into the
image (you can use `bsp` with `./bsp install stress.img` for this).

You should then install the required stress test utilities. Currently, they are
`stress-ng` and `memtester`:

```bash
sudo apt-get update && sudo apt-get install -y stress-ng memtester
```

You should then update `/config/config.txt`. Continuing above example of Radxa
ZERO, this is what we will put in that file:

```bash
echo "factory_stress PIN_7 0" | sudo tee -a /config/config.txt
```

Save and unmount the image. You can now deliver the stress test image to the QA
engineer.

## Usage

It is recommended that the first boot (if using removable storage) should NOT
set GPIO. This will allow `rsetup` service to complete the first boot configuration,
and delete `before.txt`. LEDs should be off when the above preparation is completed.
Otherwise, it will repeat the first boot configuration every boot, significantly
increasing the wait time before the QA engineer can move on to the next device.

QA engineer should then connect the GPIO pin as instructed. The status LED should
be heart beating (quick 2 blinks then some delay) initially before `rsetup` service
is started, then either switch to a consistent on-off pattern (when stress is running),
or off (when stress failed to launch).

If the stress is running, QA engineer should remove the jump wire. The stress
running status can be checked a few hours later.

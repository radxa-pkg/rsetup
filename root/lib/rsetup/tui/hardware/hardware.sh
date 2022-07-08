#!/bin/bash

__main_hardware() {
    menu_init
    menu_add __main_about "HDMI"
    menu_add __main_about "UARTs"
    menu_add __main_about "SPI"
    menu_add __main_about "I2Cs"
    menu_add __main_about "System"
    menu_add __main_about "Network"
    menu_add __main_about "About"
    menu_show "Configure Radxa product"
}
#!/bin/bash
source "$ROOT_PATH/lib/rsetup/tui/hardware/hdmi/hdmi.sh"

__main_hardware() {
    menu_init
    menu_add __hardware_boot "boot" 
    menu_add __hardware_DeviceTreeoverlays "DeviceTreeoverlays"
    menu_add __hardware_StorageDevice "Storage Device" 
    menu_add __hardware_Audio "Audio"
    menu_add __hardware_LED "LED"
    menu_add __hardware_SPI "SPI"
    menu_add __hardware_I2C "I2C" 
    menu_add __hardware_UART "UART"
    menu_add __hardware_PWM "PWM"  
    menu_add __hardware_HDMI "HDMI"  
    menu_add __main_about "About"
    menu_show "Configure Radxa product"
}
__hardware_boot() {
    menu_init
    menu_add __boot_eMMC "eMMC"
    menu_add __boot_SDcard "SD card" 
    menu_add __boot_SPIFlash "SPI Flash" 
    menu_show "Boot from"
}
__hardware_StorageDevice(){
    menu_init
    menu_add __StorageDevice_Mount "Mount"
    menu_add __StorageDevice_AutoMount "AutoMount" 
    menu_add __StorageDevice_Unmount "Unmount" 
    menu_show "Configure Storage Device"

}
__hardware_Audio (){
    menu_init
    menu_add __Audio_InternalAudiooutputselector "Internal audio output selector"
    menu_add __Audio_ExternalAudiooutputselector "External audio output selector"
    menu_show "Audio device"
}
__hardware_DeviceTreeoverlays() {
    menu_init
    menu_add __DeviceTreeoverlays_loadhardwaremodule "Load hardware module" 
    menu_show "DeviceTreeoverlays"
}
__hardware_LED(){
    menu_init
    menu_add __LED_PowerLED "Power LED"
    menu_add __LED_StatusLED "Status LED" 
    menu_show "Configure LED"
}
__LED_PowerLED(){
    menu_init
    menu_add __LED_PowerLEDon "turn Power LED on"
    menu_show "Configure PowerLED"
}
__LED_StatusLED(){
    menu_init
    menu_add __LED_StatusLEDon "turn Status LED on"
    menu_show "Configure StatusLED"

}
__hardware_SPI(){
    menu_init
    menu_add __SPI_SPI1 "SPI1"
    menu_add __SPI_SPI2 "SPI2" 
    menu_show "Configure SPI"
}
__SPI_SPI1(){
    menu_init
    menu_add __SPI1_Initial "Initial"
    menu_add __SPI1_Setfrequency "Set frequency"
    menu_add __SPI1_Setendianmode "Set endian mode"
    menu_show "Configure SPI1"
}
__SPI_SPI2(){
    menu_init
    menu_add __SPI2_Initial "Initial"
    menu_add __SPI2_Setfrequency "Set frequency"
    menu_add __SPI2_Setendianmode "Set endian mode"
    menu_show "Configure SPI2"
}
__hardware_I2C(){
    menu_init
    menu_add __I2C_I2C2 "I2C2"
    menu_add __I2C_I2C6 "I2C6"
    menu_add __I2C_I2C7 "I2C7"
    menu_show "Configure I2C"
}
__I2C_I2C2(){
    menu_init
    menu_add __I2C_enable "Enable/Disable"
    menu_add __I2C_read "read"
    menu_add __I2C_write "write"
    menu_show "Configure I2C2"
}
__hardware_UART(){
    menu_init
    menu_add __UART_UART2 "UART2"
    menu_add __UART_UART4 "UART4"
    menu_show "Configure UART BUS"
}
__hardware_PWM(){
    menu_init
    menu_add __PWM_PWM0 "PWM0"
    menu_add __PWM_PWM1 "PWM1"
    menu_show "Configure PWM"
}
__hardware_HDMI(){
    menu_init
    menu_add __HDMI_Troubleshoot "Troubleshoot"
    menu_show "Configure HDMI"
}
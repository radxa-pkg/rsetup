# shellcheck shell=bash

__overlay() {
    menu_init
    menu_add __tui_about "About"
    menu_show "Configure Device Tree Overlay"
}
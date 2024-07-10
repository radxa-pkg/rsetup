# shellcheck shell=bash
set -e
get_user_home() {
    if [ -n "${PKEXEC_UID:-}" ]; then
        getent passwd "${PKEXEC_UID}" | cut -d: -f6
    elif [ -n "${SUDO_USER:-}" ]; then
        getent passwd "${SUDO_USER}" | cut -d: -f6
    else
        getent passwd "${USER}" | cut -d: -f6
    fi
}

install_box64() {
    curl -Ls https://ryanfortner.github.io/box64-debs/box64.list > /etc/apt/sources.list.d/box64.list
    curl -Ls https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor --batch --yes -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
    apt-get update -y && apt-get install -y box64-rk3588
}

install_box86() {
    curl -Ls https://itai-nelken.github.io/weekly-box86-debs/debian/box86.list > /etc/apt/sources.list.d/box86.list
    curl -Ls https://itai-nelken.github.io/weekly-box86-debs/debian/KEY.gpg | gpg --dearmor --batch --yes -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg
    apt-get update -y && apt-get install -y box86
}

# shellcheck disable=SC2120
# files are script files and reference arguments
install_winex86() {
    local -r user_home="$(get_user_home)"
    rm -rf "${user_home}/.wine/" "${user_home}/wine/"
    # cp wine /usr/local/bin/
    cat <<EOF > /usr/local/bin/wine
#!/bin/bash
#export GALLIUM_HUD=simple,fps
setarch linux32 -L box86 $HOME/wine/bin/wine "$@"
EOF
    cat <<EOF > /usr/local/bin/wineserver
#!/bin/bash
box86 $HOME/wine/bin/wineserver "$@"
EOF
    cat <<EOF > /usr/local/bin/winetricks
#!/bin/bash
env BOX86_NOBANNER=1 box86 $HOME/wine/winetricks "$@"
EOF
    chmod +x /usr/local/bin/winetricks
    chmod +x /usr/local/bin/wineserver
    chmod +x /usr/local/bin/wine
    mkdir -p "${user_home}/.local/share/applications/"
    cat <<EOF > "${user_home}/.local/share/applications/wine-config.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Wine Configuration
Comment=Configuration utility for Wine
Icon=wine
box86 Exec=/usr/local/bin/wine winecfg
Categories=Game;
Terminal=false
EOF
    cat <<EOF > "${user_home}/.local/share/applications/wine-desktop.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Wine Desktop
Comment=Graphical desktop for Wine
Icon=wine
box86 Exec=/usr/local/bin/wine explorer /desktop=shell,1280x720 explorer.exe
Categories=Game;
Terminal=false
EOF

    mkdir "${user_home}/wine/"
    mkdir "${user_home}/wine/lib/"
    # cp libwine.so ${user_home}/wine/lib/
    # cp libwine.so.1 ${user_home}/wine/lib/
    cd "${user_home}/wine/" || exit
    latest_version="$(basename "$(curl -ILs -o /dev/null -w "%{url_effective}" https://github.com/Kron4ek/Wine-Builds/releases/latest)")"
    curl -Ls "https://github.com/Kron4ek/Wine-Builds/releases/download/$latest_version/wine-$latest_version-x86.tar.xz" > "wine-latest-x86.tar.xz"
    xz -d wine-latest-x86.tar.xz
    tar -xf wine-latest-x86.tar
    cd "wine-$latest_version-x86/" || exit
    cp -R ./* "${user_home}/wine"
    # ln -s "${user_home}/wine/bin/wine" /usr/local/bin/wine
    # ln -s "${user_home}/wine/bin/winecfg" /usr/local/bin/winecfg
    # ln -s "${user_home}/wine/bin/wineserver" /usr/local/bin/wineserver
    # #try to chown using either sudo_user or pkexec_uid
    chown -R "${SUDO_USER:-${PKEXEC_UID}}" "${user_home}/wine"
    echo "Run wine winecfg to let wine configure itself"
}

# install_wine64() {
#     __parameter_count_check 0 "$@"
#     local -r user_home="$(get_user_home)"
#     rm -r ~/.wine/
#     rm -r ~/wine/
#     cd ~
#     wget https://github.com/Kron4ek/Wine-Builds/releases/download/8.16/wine-8.16-amd64.tar.xz
#     mkdir ~/wine
#     cd ~/wine
#     xz -d ../wine-8.16-amd64.tar.xz
#     tar -xvf ../wine-8.16-amd64.tar
#     rm /usr/local/bin/wine /usr/local/bin/wineboot /usr/local/bin/winecfg /usr/local/bin/wineserver /usr/local/bin/wine64
#     cd wine-8.16-amd64/
#     ln -s ~/wine/wine-8.16-amd64/bin/wine /usr/local/bin/wine
#     ln -s ~/wine/wine-8.16-amd64/bin/wine64 /usr/local/bin/wine64
#     ln -s ~/wine/wine-8.16-amd64/bin/wineserver /usr/local/bin/wineserver
#     ln -s ~/wine/wine-8.16-amd64/bin/winecfg /usr/local/bin/winecfg
#     ln -s ~/wine/wine-8.16-amd64/bin/wineboot /usr/local/bin/wineboot
#     cd ~
#     rm wine-8.16-amd64.tar.xz
# }


install_steam() {
    __parameter_count_check 0 "$@"
    local -r user_home="$(get_user_home)"
    dpkg --add-architecture armhf
    install_box86
    install_box64
    install_winex86
    # install_wine64
    # create necessary directories
    mkdir -p "${user_home}/steam"
    mkdir -p "${user_home}/steam/tmp"
    cd "${user_home}/steam/tmp" || exit

    # download latest deb and unpack
    wget https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb
    ar x steam.deb
    tar xf data.tar.xz

    # remove deb archives, not needed anymore
    rm ./*.tar.xz ./steam.deb

    # move deb contents to steam folder
    mv ./usr/* ../
    cd ../ && rm -rf ./tmp/

    # create run script
    echo '#!/bin/bash
export STEAMOS=1
export STEAM_RUNTIME=1
export DBUS_FATAL_WARNINGS=0
~/steam/bin/steam $@' > steam

    # make script executable and move
    chmod +x steam
    mv steam /usr/local/bin/
    apt-get install -y libc6:armhf libsdl2-2.0-0:armhf libsdl2-image-2.0-0:armhf \
        libsdl2-mixer-2.0-0:armhf libsdl2-ttf-2.0-0:armhf libopenal1:armhf \
        libpng16-16:armhf libfontconfig1:armhf libxcomposite1:armhf \
        libbz2-1.0:armhf libxtst6:armhf libsm6:armhf libice6:armhf \
        libxinerama1:armhf libxdamage1:armhf libdrm2:armhf libgbm1:armhf libibus-1.0-5

}

uninstall_steam() {
    local -r user_home="$(get_user_home)"

    # Remove Box64
    rm /etc/apt/sources.list.d/box64.list
    rm /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
    apt-get remove -y box64-rk3588

    # Remove Box86
    rm /etc/apt/sources.list.d/box86.list
    rm /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg
    apt-get remove -y box86

    # Remove Wine related files and directories
    rm -rf "${user_home}/.wine" "${user_home}/wine"
    rm -f /usr/local/bin/wine /usr/local/bin/wineserver /usr/local/bin/winetricks
    rm -f "${user_home}/.local/share/applications/wine-config.desktop"
    rm -f "${user_home}/.local/share/applications/wine-desktop.desktop"

    # Remove Steam related files and directories
    rm -rf "${user_home}/steam"
    rm -f /usr/local/bin/steam

    # Remove additional packages installed for Steam
    apt-get remove -y libc6:armhf libsdl2-2.0-0:armhf libsdl2-image-2.0-0:armhf \
        libsdl2-mixer-2.0-0:armhf libsdl2-ttf-2.0-0:armhf libopenal1:armhf \
        libpng16-16:armhf libfontconfig1:armhf libxcomposite1:armhf \
        libbz2-1.0:armhf libxtst6:armhf libsm6:armhf libice6:armhf \
        libxinerama1:armhf libxdamage1:armhf libgbm1:armhf libdrm2:armhf


    # Remove armhf architecture
    if ! dpkg --remove-architecture armhf; then
        echo "Failed to remove the armhf architecture. There might be some packages that are still using it."
    fi

    # Update apt repositories and clean up
    apt-get update -y
    apt-get remove -y
}

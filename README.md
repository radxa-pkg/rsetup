# rsetup

[![Build & Release](https://github.com/radxa-pkg/rsetup/actions/workflows/release.yml/badge.svg)](https://github.com/radxa-pkg/rsetup/actions/workflows/release.yml)

Radxa system setup utility

## Development dependencies

Arch

```bash
sudo tee -a /etc/devscripts.conf <<< 'DEBUILD_DPKG_BUILDPACKAGE_OPTS="-d"'
yay -Syu apt dpkg devscripts lintian pandoc shellcheck git-buildpackage
```

Debian

```bash
sudo apt-get update
sudo apt-get build-dep --no-install-recommends .
sudo apt-get install git-buildpackage
```

## Usage

`make run`: run local version of rsetup

`make DEBUG=1 run`: run local version of rsetup in debug mode

`make test`: run ShellCheck

`make deb`: create Debian package
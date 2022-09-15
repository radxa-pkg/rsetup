# rsetup

[![Build & Release](https://github.com/radxa-pkg/rsetup/actions/workflows/release.yml/badge.svg)](https://github.com/radxa-pkg/rsetup/actions/workflows/release.yml)

Radxa system setup utility

## Development dependencies

Packages listed below are incomplete. This is currently a place holder.

Arch

```
yay -Syu apt dpkg devscripts lintian
```

Debian

```
sudo apt update
sudo apt full-upgrade -y lintian
```

## Usage

`make run`: run local version of rsetup

`make DEBUG=1 run`: run local version of rsetup in debug mode

`make test`: run ShellCheck

`make deb`: create Debian package
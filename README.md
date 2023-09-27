# rsetup

[![Build & Release](https://github.com/radxa-pkg/rsetup/actions/workflows/release.yml/badge.svg)](https://github.com/radxa-pkg/rsetup/actions/workflows/release.yml)

Radxa system setup utility

## Usage

Run `rsetup` to launch the user interface.

## Development dependencies

<details>
<summary>Arch</summary>

```bash
yay -Syu devscripts dh-autoreconf dh-strip-nondeterminism git-buildpackage pandoc shellcheck
sudo tee -a /etc/devscripts.conf <<< 'DEBUILD_DPKG_BUILDPACKAGE_OPTS="-d"'
# Install missing dependencies of debhelper's dependencies
yay -Syu perl-sub-override
# Install missing dependencies of debhelper
yay -Syu dh-autoreconf dh-strip-nondeterminism

# As of 2022-09-22, it is not easy to install lintian on Arch right now.
# So here is a dedicated section for it.
#
# lintian depends on apt, which is currently broken on AUR
mkdir -p ~/.cache/yay/apt
wget https://github.com/Debian/apt/pull/133.patch -O ~/.cache/yay/apt/133.patch
yay -Syu --editmenu apt
# When editing apt's PKGBUILD, add the following info to support patching
# source 133.patch
# sha512sums 07256958ee808c1a07476c4f95df603c964174e910866553db1023e24b797219217333369816a5d38791761e5b7446f9f311b602521d1658038e31a51dc8556d
# prepare() {
#    patch --directory="$pkgname-$pkgver" --forward --strip=1 --input="${srcdir}/133.patch"
#}
# Additional missing make dependcies for lintian's dependencies
yay -Syu perl-iterator perl-test-requires perl-module-build-tiny
# Additional missing make dependcies for lintian
yay -Syu python-docutils
# Finally install lintian
yay -Syu lintian
# Additional missing lintian runtime dependencies
yay -Syu perl-data-validate-uri perl-list-someutils perl-moox-aliases perl-namespace-clean perl-path-tiny perl-xml-libxml
# Copy profile for Arch
sudo cp -r /usr/share/lintian/profiles/debian/. /usr/share/lintian/profiles/archlinux/
```

</details>

<details>
<summary>Debian</summary>

```bash
sudo apt-get update
sudo apt-get build-dep --no-install-recommends .
sudo apt-get install git-buildpackage
```

</details>

## Developer commands

`make run`: run local version of rsetup

`make debug`: run local version of rsetup in debug mode

`make test`: run ShellCheck

`make dch`: generate changelog from git log

`make deb`: create Debian package

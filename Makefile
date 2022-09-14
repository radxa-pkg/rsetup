include /usr/share/dpkg/pkg-info.mk

PACKAGE=rsetup

GITVERSION:=$(shell git rev-parse HEAD)

DEB=${PACKAGE}_${DEB_VERSION_UPSTREAM_REVISION}_all.deb

BUILD_DIR=build

all: deb
deb: ${DEB}

${DEB}: debian
	rm -rf ${BUILD_DIR}
	mkdir -p ${BUILD_DIR}/debian
	cp -ar debian/* ${BUILD_DIR}/debian/
	cp -ar root ${BUILD_DIR}/
	echo "git clone $(shell git remote get-url origin)\\ngit checkout ${GITVERSION}" > ${BUILD_DIR}/debian/SOURCE
	pandoc "${BUILD_DIR}/debian/${PACKAGE}.8.md" -o "${BUILD_DIR}/debian/${PACKAGE}.8" --from markdown --to man -s
	cd ${BUILD_DIR}; dpkg-buildpackage ${DPKG_FLAGS} -b -uc -us
	lintian ${DEB}

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf *~ ${BUILD_DIR} *.deb *.dsc *.changes *.buildinfo

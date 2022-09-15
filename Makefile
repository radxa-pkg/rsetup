include /usr/share/dpkg/pkg-info.mk
include /usr/share/dpkg/architecture.mk

.PHONY: all
all:

.PHONY: deb
deb: debian
	debuild --no-sign

.PHONY: run
run:
	sudo DEBUG=${DEBUG} usr/bin/rsetup

.PHONY: test
test:
	shellcheck -x usr/bin/rsetup
	find lib/ -name '*.sh' -exec shellcheck -x {} +

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf debian/.debhelper debian/${DEB_SOURCE} debian/debhelper-build-stamp debian/files debian/${DEB_SOURCE}.8 debian/${DEB_SOURCE}.debhelper.log debian/${DEB_SOURCE}.postrm.debhelper debian/${DEB_SOURCE}.substvars debian/SOURCE

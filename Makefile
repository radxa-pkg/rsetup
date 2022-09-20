PROJECT ?= rsetup
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
MANDIR ?= $(PREFIX)/share/man

.PHONY: all
all: build

#
# Development
#
.PHONY: run
run:
	usr/bin/rsetup

.PHONY: debug
debug:
	sudo DEBUG=true bash usr/bin/rsetup
#
# Test
#
.PHONY: test
test:
	find usr -type f \( -name "*.sh" -o -name "rsetup" \) -exec shellcheck -x {} +

#
# Build
#
.PHONY: build
build: build-man build-doc

SRC-MAN		:=	man
SRCS-MAN	:=	$(wildcard $(SRC-MAN)/*.md)
MANS		:=	$(SRCS-MAN:.md=)
.PHONY: build-man
build-man: $(MANS)

$(SRC-MAN)/%: $(SRC-MAN)/%.md
	pandoc "$<" -o "$@" --from markdown --to man -s

SRC-DOC		:=	.
DOCS		:=	$(SRC-DOC)/SOURCE
build-doc: $(DOCS)

$(SRC-DOC):
	mkdir -p $(SRC-DOC)

.PHONY: $(SRC-DOC)/SOURCE
$(SRC-DOC)/SOURCE: $(SRC-DOC)
	echo -e "git clone $(shell git remote get-url origin)\ngit checkout $(shell git rev-parse HEAD)" > "$@"

#
# Install
#
.PHONY: install
install: install-man
	install -d $(DESTDIR)$(LIBDIR)/rsetup
	cp -R usr/lib/rsetup/. $(DESTDIR)$(LIBDIR)/rsetup
	find $(DESTDIR)$(LIBDIR)/rsetup -type f -exec chmod 644 {} +

	install -d $(DESTDIR)$(LIBDIR)/systemd/system
	install -m 644 usr/lib/systemd/system/rsetup.service $(DESTDIR)$(LIBDIR)/systemd/system

	install -d $(DESTDIR)$(BINDIR)
	install -m 755 usr/bin/rsetup $(DESTDIR)$(BINDIR)/rsetup

.PHONY: install-man
install-man: build-man
	install -d $(DESTDIR)$(MANDIR)/man8
	install -m 644 $(SRC-MAN)/*.8 $(DESTDIR)$(MANDIR)/man8/

#
# Clean
#
.PHONY: distclean
distclean: clean

.PHONY: clean
clean: clean-man clean-doc clean-deb

.PHONY: clean-man
clean-man:
	rm -rf $(MANS)

.PHONY: clean-doc
clean-doc:
	rm -rf $(DOCS)

.PHONY: clean-deb
clean-deb:
	rm -rf debian/.debhelper debian/${PROJECT} debian/debhelper-build-stamp debian/files debian/*.debhelper.log debian/*.postrm.debhelper debian/*.substvars

#
# Release
#
.PHONY: dch
dch: debian/changelog
	gbp dch --debian-branch=main

.PHONY: deb
deb: debian
	debuild --no-sign

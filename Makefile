include /usr/share/dpkg/pkg-info.mk
include /usr/share/dpkg/architecture.mk

.PHONY: all
all: build

#
# Development
#
.PHONY: run
run:
	sudo DEBUG=${DEBUG} usr/bin/rsetup

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
# Test
#
.PHONY: test
test:
	shellcheck -x usr/bin/rsetup
	find lib/ -name '*.sh' -exec shellcheck -x {} +

#
# Install
#

#
# Clean
#
.PHONY: distclean
distclean: clean

.PHONY: clean
clean: clean-man clean-doc
	rm -rf debian/.debhelper debian/${DEB_SOURCE} debian/debhelper-build-stamp debian/files debian/*.debhelper.log debian/*.postrm.debhelper debian/*.substvars

.PHONY: clean-man
clean-man:
	rm -rf $(MANS)

.PHONY: clean-doc
clean-doc:
	rm -rf $(DOCS)

#
# Release
#
.PHONY: deb
deb: debian
	debuild --no-sign

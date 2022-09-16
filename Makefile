include /usr/share/dpkg/pkg-info.mk
include /usr/share/dpkg/architecture.mk

.PHONY: all
all: build

.PHONY: build
build: build-man

SRC-MAN		:=	man
SRCS-MAN	:=	$(wildcard $(SRC-MAN)/*.md)
MANS		:=	$(SRCS-MAN:.md=)
.PHONY: build-man
build-man: $(MANS)

$(SRC-MAN)/%: $(SRC-MAN)/%.md
	pandoc "$<" -o "$@" --from markdown --to man -s

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
clean: clean-man
	rm -rf debian/.debhelper debian/${DEB_SOURCE} debian/debhelper-build-stamp debian/files debian/${DEB_SOURCE}.debhelper.log debian/${DEB_SOURCE}.postrm.debhelper debian/${DEB_SOURCE}.substvars debian/SOURCE

.PHONY: clean-man
clean-man:
	find $(SRC-MAN) -mindepth 1 ! -name '*.md' ! -name '.gitignore' -delete
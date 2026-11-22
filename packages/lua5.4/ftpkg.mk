
PKG_NAME :=lua
PKG_DEFAULT :=y

ifndef FTPKG_GENERATING
MAKEFLAGS += -r -R

include $(FT_PKGINC)

# do not leak upper level make flags:
unexport MFLAGS
unexport MAKEFLAGS

PKG_BCMD =$(MAKE) CC=$(FT_CC) FT_CLPFX=$(FT_CLPFX) \
	FT_PREFIX=$(FT_PREFIX) MYCFLAGS="$(FT_CFLAGS)" MYLDFLAGS="$(FT_LDFLAGS)"

.PHONY: prepare compile install clean

prepare:
	@: Nothing TODO for prepare ; exit 0
compile:
	@$(PKG_BCMD) -j4 INSTALL_TOP=$(FT_PREFIX) linux
install:
	$(PKG_BCMD) -j1 INSTALL_TOP=$(FT_DESTPFX) install
clean:
	@$(MAKE) clean
endif

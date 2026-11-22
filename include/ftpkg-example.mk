#
# Copyright 2021 Ye Holmes <yeholmes@outlook.com>
#
# Makefile template for Fighter package

PKG_NAME :=ftpkg-example
PKG_DEFAULT :=y

ifndef FTPKG_GENERATING
MAKEFLAGS += -r -R

include $(FT_PKGINC)

# do not leak upper level make flags:
unexport MFLAGS
unexport MAKEFLAGS

CFLAGS   :=$(FT_CFLAGS) -D_GNU_SOURCE \
	-I$(FT_DESTPFX)/include -fPIC -D_FILE_OFFSET_BITS=64
LDFLAGS  :=$(FT_LDFLAGS) -lpthread

.PHONY: prepare compile install clean
prepare:
	@echo "Nothing TODO to prepare for $(PKG_NAME)" ; exit 0
compile: ftpkg-example
ftpkg-example: ftpkg-example.c
	@echo $(FT_CC) $(CFLAGS) -o $@ $^ -Wl,-soname=$@ $(LDFLAGS)
install: ftpkg-example
	@mkdir -p $(FT_DESTPFX)/bin
	@cp -v $^ $(FT_DESTPFX)/bin/
clean:
	@rm -rf *.o *.a *.so* ftpkg-example

endif # FTPKG_GENERATING

# Makefile template for Fighter package

PKG_NAME :=lua-cjson
PKG_DEFAULT :=y

ifndef FTPKG_GENERATING
MAKEFLAGS += -r -R

include $(FT_PKGINC)

# do not leak upper level make flags:
unexport MFLAGS
unexport MAKEFLAGS

CFLAGS   :=$(FT_CFLAGS) -D_GNU_SOURCE \
	-I$(FT_DESTPFX)/include -fPIC -D_FILE_OFFSET_BITS=64

.PHONY: prepare compile install clean
prepare:
	@echo "Nothing TODO to prepare for $(PKG_NAME)" ; exit 0
compile: cjson.so
cjson.so:
	@$(MAKE) -j1 CC=$(FT_CC) "CFLAGS=$(CFLAGS)" "LDFLAGS=$(FT_LDFLAGS)" PREFIX=/tmp/not/found $@
install: cjson.so
	@mkdir -p $(FT_DESTPFX)/lib/lua/5.4
	@cp -v $^ $(FT_DESTPFX)/lib/lua/5.4/
clean:
	@rm -rf *.o *.a *.so*

endif # FTPKG_GENERATING

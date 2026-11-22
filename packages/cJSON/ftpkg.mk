# Makefile template for Fighter package

PKG_NAME :=cJSON
PKG_DEFAULT :=n

ifndef FTPKG_GENERATING
MAKEFLAGS += -r -R

include $(FT_PKGINC)

# do not leak upper level make flags:
unexport MFLAGS
unexport MAKEFLAGS

# CFLAGS   :=$(FT_CFLAGS) -D_GNU_SOURCE \
	-I$(FT_DESTPFX)/include -fPIC -D_FILE_OFFSET_BITS=64
# LDFLAGS  :=$(FT_LDFLAGS) -lpthread

.PHONY: prepare compile install clean
prepare:
	@mkdir -p ./build_dir && cd ./build_dir && cmake \
		-DCMAKE_INSTALL_PREFIX=$(FT_PREFIX) -DCMAKE_BUILD_TYPE=RelWithDebInfo \
		-DCMAKE_C_COMPILER=$(FT_CC) -DCMAKE_CXX_COMPILER=$(FT_CXX) \
		'-DCMAKE_C_FLAGS=$(FT_CFLAGS)' '-DCMAKE_CXX_FLAGS=$(FT_CFLAGS)' \
		'-DCMAKE_EXE_LINKER_FLAGS=$(FT_LDFLAGS)' \
		'-DCMAKE_MODULE_LINKER_FLAGS=$(FT_LDFLAGS)' \
		'-DCMAKE_SHARED_LINKER_FLAGS=$(FT_LDFLAGS)' \
		-DENABLE_CJSON_TEST=OFF -DENABLE_LOCALES=OFF ..
compile:
	@cd ./build_dir && $(MAKE) VERBOSE=1 -j1
install:
	@cd ./build_dir && $(MAKE) DESTDIR=$(FT_DESTDIR) VERBOSE=1 -j1 install
clean:
	@rm -rf ./build_dir

endif # FTPKG_GENERATING

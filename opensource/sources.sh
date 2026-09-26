#!/bin/bash

# Created by yejq.jiaqiang@gmail.com
# Simple Script to compile opensource tarballs
# 2026/09/26

lua51_config() {
	apply_patches ../patches-lua-5.1.5
	return $?
}

lua51_compile() {
	make PLAT=linux EXTRA_CFLAGS="'-DLUA_ROOT=\"${FTI_PREFIX}\"'" \
		CROSS_COMPILE="${FTC_PREFIX}" INSTALL_TOP="${FTI_PREFIX}" -j1 all
	[ $? -ne 0 ] && return 1

	make PLAT=linux EXTRA_CFLAGS="'-DLUA_ROOT=\"${FTI_PREFIX}\"'" \
		CROSS_COMPILE="${FTC_PREFIX}" INSTALL_TOP="${FSTAGING_DIR}${FTI_PREFIX}" -j1 install
	return $?
}

lua51_clean() {
	make PLAT=linux clean
	return 0
}

opensource_clean() {
	local mkfile
	for mkfile in Makefile GNUMakefile makefile ; do
		[ -f "${mkfile}" ] && make -f "${mkfile}" clean
	done
	find ./ -type f -name '*.o' -delete
	find ./ -type f -name '*.a' -delete
	find ./ -type f -name '*.so' -delete
	rm -rf install_manifest.txt CMakeFiles CMakeCache.txt cmake_install.cmake
	return 0
}

opensource_build() {
	make VERBOSE=1 -j4
	[ $? -ne 0 ] && return 1

	make VERBOSE=1 DESTDIR=${FSTAGING_DIR} -j1 install
	[ $? -ne 0 ] && return 2

	cd "${FSTAGING_DIR}${FTI_PREFIX}/lib" && rm -f -v *.a
	return 0
}

jsonc_config() {
	cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=${FTI_PREFIX} \
		-DCMAKE_C_COMPILER=${FTC_CC} -DCMAKE_C_COMPILER_RANLIB=${FTC_RANLIB} \
		-DBUILD_STATIC_LIBS=OFF -DBUILD_SHARED_LIBS=ON \
		-DCMAKE_EXE_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_SHARED_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_MODULE_LINKER_FLAGS="${FTC_LDFLAGS}" .
	return $?
}

libubox_config() {
	apply_patches ../patches-libubox
	[ $? -ne 0 ] && return 1

	PKG_CONFIG_PATH=${FSTAGING_DIR}${FTI_PREFIX}/lib/pkgconfig \
	cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX="${FTI_PREFIX}" \
		-DCMAKE_C_COMPILER=${FTC_CC} -DCMAKE_AR="$(which ${FTC_AR})" \
		-DCMAKE_C_COMPILER_RANLIB=${FTC_RANLIB} -DBUILD_LUA=ON -DBUILD_EXAMPLES=OFF \
		-DJSONC_INCLUDE_DIRS=${FSTAGING_DIR}${FTI_PREFIX}/include/json-c \
		-Djson=${FSTAGING_DIR}${FTI_PREFIX}/lib/libjson-c.so \
		-DLUA_CFLAGS="-I${FSTAGING_DIR}${FTI_PREFIX}/include" \
		-DLUAPATH="${FTI_PREFIX}/lib/lua" \
		-DCMAKE_EXE_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_SHARED_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_MODULE_LINKER_FLAGS="${FTC_LDFLAGS}" .
	return $?
}

uci_config() {
	apply_patches ../patches-uci
	[ $? -ne 0 ] && return 1

	PKG_CONFIG_PATH=${FSTAGING_DIR}${FTI_PREFIX}/lib/pkgconfig \
	cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX="${FTI_PREFIX}" \
		-DCMAKE_C_COMPILER=${FTC_CC} -DCMAKE_AR="$(which ${FTC_AR})" \
		-DCMAKE_C_COMPILER_RANLIB=${FTC_RANLIB} -DBUILD_LUA=ON -DBUILD_STATIC=OFF \
		-DLUA_CFLAGS="-I${FSTAGING_DIR}${FTI_PREFIX}/include" \
		-DLUAPATH="${FTI_PREFIX}/lib/lua" \
		-Dubox=${FSTAGING_DIR}${FTI_PREFIX}/lib/libubox.so \
		-Dubox_include_dir="${FSTAGING_DIR}${FTI_PREFIX}/include" \
		-DCMAKE_EXE_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_SHARED_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_MODULE_LINKER_FLAGS="${FTC_LDFLAGS}" .
	return $?
}

ubus_config() {
	apply_patches ../patches-ubus
	[ $? -ne 0 ] && return 1

	PKG_CONFIG_PATH=${FSTAGING_DIR}${FTI_PREFIX}/lib/pkgconfig \
	cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX="${FTI_PREFIX}" \
		-DCMAKE_C_COMPILER=${FTC_CC} -DCMAKE_AR="$(which ${FTC_AR})" \
		-DCMAKE_C_COMPILER_RANLIB=${FTC_RANLIB} \
		-DBUILD_LUA=ON -DBUILD_EXAMPLES=OFF -DBUILD_STATIC=OFF \
		-DLUA_CFLAGS="-I${FSTAGING_DIR}${FTI_PREFIX}/include" \
		-DLUAPATH="${FTI_PREFIX}/lib/lua" \
		-Dubox_library=${FSTAGING_DIR}${FTI_PREFIX}/lib/libubox.so \
		-Dblob_library=${FSTAGING_DIR}${FTI_PREFIX}/lib/libblobmsg_json.so \
		-Djson=${FSTAGING_DIR}${FTI_PREFIX}/lib/libjson-c.so \
		-Dubox_include_dir="${FSTAGING_DIR}${FTI_PREFIX}/include" \
		-DCMAKE_EXE_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_SHARED_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_MODULE_LINKER_FLAGS="${FTC_LDFLAGS}" .
	return $?
}

libnl_tiny_config() {
	apply_patches ../patches-libnl-tiny
	[ $? -ne 0 ] && return 1

	cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX="${FTI_PREFIX}" \
		-DCMAKE_C_COMPILER=${FTC_CC} -DCMAKE_AR="$(which ${FTC_AR})" \
		-DCMAKE_C_COMPILER_RANLIB=${FTC_RANLIB} \
		-DCMAKE_EXE_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_SHARED_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_MODULE_LINKER_FLAGS="${FTC_LDFLAGS}" .
	return $?
}

jsonfilter_config() {
	cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX="${FTI_PREFIX}" \
		-DCMAKE_C_COMPILER=${FTC_CC} -DCMAKE_AR="$(which ${FTC_AR})" \
		-DCMAKE_C_COMPILER_RANLIB=${FTC_RANLIB} \
		-Djson=${FSTAGING_DIR}${FTI_PREFIX}/lib/libjson-c.so \
		-Dubox_include_dir=${FSTAGING_DIR}${FTI_PREFIX}/include \
		-DCMAKE_EXE_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_SHARED_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_MODULE_LINKER_FLAGS="${FTC_LDFLAGS}" .
	return $?
}

jsonfilter_build() {
	opensource_build
	[ $? -ne 0 ] && return 1
	cd "${FSTAGING_DIR}${FTI_PREFIX}/bin" && \
		[ ! -L jsonpath ] && \
		mv -v -f jsonpath jsonfilter && \
		ln -sv jsonfilter jsonpath
	return $?
}

iw_utils_config() {
	apply_patches ../patches-iw
	return $?
}

iw_utils_build() {
	local IW_CFLAGS="-I${FSTAGING_DIR}${FTI_PREFIX}/include/libnl-tiny"
	make IW_FULL=1 CC=${FTC_CC} CFLAGS="${IW_CFLAGS} -DCONFIG_LIBNL20" V=1 \
		LDFLAGS="${FTC_LDFLAGS}" LIBS="-lm -lnl-tiny" NL1FOUND="" NL2FOUND=Y NLLIBNAME="libnl-tiny" -j1
	[ $? -ne 0 ] && return 1

	mkdir -p "${FSTAGING_DIR}${FTI_PREFIX}/sbin"
	cp -v iw "${FSTAGING_DIR}${FTI_PREFIX}/sbin/"
	return $?
}

register_source "lua-5.1.5.tar.gz" \
	lua51_config lua51_compile lua51_clean

register_source "json-c-0.18.tar.gz" \
	jsonc_config opensource_build opensource_clean

register_source "opensource/libubox" \
	libubox_config opensource_build opensource_clean

register_source "opensource/uci" \
	uci_config opensource_build opensource_clean

register_source "opensource/ubus" \
	ubus_config opensource_build opensource_clean

register_source "opensource/libnl-tiny" \
	libnl_tiny_config opensource_build opensource_clean

register_source "opensource/jsonfilter" \
	jsonfilter_config jsonfilter_build opensource_clean

register_source "iw-6.17.tar.xz" \
	iw_utils_config iw_utils_build opensource_clean

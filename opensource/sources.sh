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
		-DCMAKE_C_COMPILER=${FTC_CC} -DCMAKE_C_FLAGS="${FTC_CFLAGS}" \
		-DCMAKE_C_COMPILER_RANLIB=${FTC_RANLIB} \
		-DBUILD_STATIC_LIBS=OFF -DBUILD_SHARED_LIBS=ON \
		-DCMAKE_EXE_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_SHARED_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_MODULE_LINKER_FLAGS="${FTC_LDFLAGS}" .
	return $?
}

register_source "lua-5.1.5.tar.gz" \
	lua51_config lua51_compile lua51_clean

register_source "json-c-0.18.tar.gz" \
	jsonc_config opensource_build opensource_clean

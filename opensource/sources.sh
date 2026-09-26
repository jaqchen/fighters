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

libmd_config() {
	./configure --host=${FTC_HOST} --prefix=${FTI_PREFIX} CC=${FTC_CC} \
		LDFLAGS="${FTC_LDFLAGS}" --enable-static=yes --enable-shared=yes
	return $?
}

libmd_build() {
	make V=1 -j4
	[ $? -ne 0 ] && return 1

	make V=1 DESTDIR=${FSTAGING_DIR} -j1 install
	[ $? -ne 0 ] && return 2

	cd "${FSTAGING_DIR}${FTI_PREFIX}/lib" && rm -f -v *.a
	return 0
}

ucode_config() {
	apply_patches ../patches-ucode
	[ $? -ne 0 ] && return 1

	PKG_CONFIG_PATH=${FSTAGING_DIR}${FTI_PREFIX}/lib/pkgconfig \
	cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX="${FTI_PREFIX}" \
		-DCMAKE_C_COMPILER=${FTC_CC} -DLINUX=ON -DCMAKE_AR="$(which ${FTC_AR})" \
		-DCMAKE_C_COMPILER_RANLIB=${FTC_RANLIB} \
		-Djson=${FSTAGING_DIR}${FTI_PREFIX}/lib/libjson-c.so \
		-Duci_include_dir=${FSTAGING_DIR}${FTI_PREFIX}/include \
		-Dnl_include_dir=${FSTAGING_DIR}${FTI_PREFIX}/include/libnl-tiny \
		-Duloop_include_dir=${FSTAGING_DIR}${FTI_PREFIX}/include \
		-Dubus_include_dir=${FSTAGING_DIR}${FTI_PREFIX}/include \
		-Dulog_include_dir=${FSTAGING_DIR}${FTI_PREFIX}/include \
		-Dlibmd=${FSTAGING_DIR}${FTI_PREFIX}/lib/libmd.so \
		-Dlibuci=${FSTAGING_DIR}${FTI_PREFIX}/lib/libuci.so \
		-Dlibubox=${FSTAGING_DIR}${FTI_PREFIX}/lib/libubox.so \
		-Dlibubus=${FSTAGING_DIR}${FTI_PREFIX}/lib/libubus.so \
		-Dlibnl_tiny=${FSTAGING_DIR}${FTI_PREFIX}/lib/libnl-tiny.so \
		-Dlibblobmsg_json=${FSTAGING_DIR}${FTI_PREFIX}/lib/libblobmsg_json.so \
		-DCMAKE_EXE_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_SHARED_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_MODULE_LINKER_FLAGS="${FTC_LDFLAGS}" .
	return $?
}

udebug_config() {
	apply_patches ../patches-udebug
	[ $? -ne 0 ] && return 1

	PKG_CONFIG_PATH=${FSTAGING_DIR}${FTI_PREFIX}/lib/pkgconfig \
	cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX="${FTI_PREFIX}" \
		-DCMAKE_C_COMPILER=${FTC_CC} -DCMAKE_AR="$(which ${FTC_AR})" \
		-DCMAKE_C_COMPILER_RANLIB=${FTC_RANLIB} \
		-Dubus_include_dir=${FSTAGING_DIR}${FTI_PREFIX}/include \
		-Ducode_include_dir=${FSTAGING_DIR}${FTI_PREFIX}/include \
		-Duloop_include_dir=${FSTAGING_DIR}${FTI_PREFIX}/include \
		-Dubox=${FSTAGING_DIR}${FTI_PREFIX}/lib/libubox.so \
		-Dubus=${FSTAGING_DIR}${FTI_PREFIX}/lib/libubus.so \
		-DCMAKE_EXE_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_SHARED_LINKER_FLAGS="${FTC_LDFLAGS}" \
		-DCMAKE_MODULE_LINKER_FLAGS="${FTC_LDFLAGS}" .
	return $?
}

openssl_config() {
	local SSL_TARGET
	if [[ ${FTC_CC} =~ ^arm- ]] ; then
		SSL_TARGET=linux-arm-openwrt
	elif [[ ${FTC_CC} =~ ^aarch64- ]] ; then
		SSL_TARGET=linux-aarch64-openwrt
	elif [[ ${FTC_CC} =~ ^x86_64- ]] ; then
		SSL_TARGET=linux-x86_64-openwrt
	else
		echo "Error, unsupported toolchain for openssl: ${FTC_CC}"
		return 1
	fi

	apply_patches ../patches-openssl
	[ $? -ne 0 ] && return 2

	CFLAGS="${FTC_CFLAGS}" LDFLAGS="${FTC_LDFLAGS}" \
	./Configure "${SSL_TARGET}" --prefix=${FTI_PREFIX} --libdir=lib --openssldir="${FTI_PREFIX}/etc/ssl" \
		--cross-compile-prefix=${FTC_PREFIX} shared no-tests no-comp
	return $?
}

openssl_build() {
	make CC=${FTC_CC} -j4 all
	[ $? -ne 0 ] && return 1

	make CC=${FTC_CC} -j1 DESTDIR="${FSTAGING_DIR}" install_sw install_ssldirs
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

register_source 'libmd-1.2.0.tar.xz' \
	libmd_config libmd_build opensource_clean

register_source "opensource/ucode" \
	ucode_config opensource_build opensource_clean

register_source "opensource/udebug" \
	udebug_config opensource_build opensource_clean

register_source 'openssl-3.5.7.tar.gz' \
	openssl_config openssl_build opensource_clean

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

register_source "lua-5.1.5.tar.gz" \
	lua51_config lua51_compile lua51_clean

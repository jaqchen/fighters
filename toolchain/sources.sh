#!/bin/bash

# Created by yejq.jiaqiang@gmail.com
# Simple Shell Script to compile toolchain wrappers
# 2026/09/26

toolchain_build() {
	local oldir="${PWD}"

	cd "${FTOPDIR}/toolchain" || return 1
	if [ ! -e "${TAG_BUILT}" ] ; then
		make EXTC_ROOT="${TOOLCHAIN_DIR}" FTC_PREFIX="${FTC_PREFIX}" \
			FTC_FLAGS="${FTC_CFLAGS}" all
		if [ $? -ne 0 ] ; then
			echo "Error, failed to generated toolchain wrapper." 1>&2
			return 2
		fi
		touch "${TAG_BUILT}"
	fi
	return 0
}

# invoke the toolchain wrapper build unconditionally
toolchain_build

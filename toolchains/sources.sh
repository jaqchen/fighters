#!/bin/bash

# Created by yejq.jiaqiang@gmail.com
# Simple Shell Script to compile toolchain wrappers
# 2026/09/26

toolchains_build() {
	if [ -z "${TOOLCHAIN_DIR}" ] ; then
		echo "Error, \`TOOLCHAIN_DIR not defined."
		return 1
	fi

	local oldir="${PWD}"
	cd "${FTOPDIR}/toolchains" || return 2
	if [ ! -e "${TAG_BUILT}" ] ; then
		make "EXTC_ROOT=${TOOLCHAIN_DIR}" "FTC_PREFIX=${FTC_PREFIX}" \
			"FTC_FLAGS=${FTC_FLAGS}" all
		if [ $? -ne 0 ] ; then
			echo "Error, failed to generated toolchain wrapper." 1>&2
			cd "${oldir}"
			return 3
		fi
		touch "${TAG_BUILT}"
	fi

	cd "${oldir}"
	return 0
}

# invoke the toolchain wrapper build unconditionally
toolchains_build

# Simple build configuration for x86_64

FT_HOST      := aarch64-buildroot-linux-musl
FT_CLPFX     := aarch64-buildroot-linux-musl-
FT_CC        := $(FT_CLPFX)gcc
FT_CXX       := $(FT_CLPFX)g++
FT_PREFIX    := /opt/ftaddon
FT_CFLAGS    := -Wall -fPIC -O2 -D_GNU_SOURCE -ggdb -fno-omit-frame-pointer
FT_DESTDIR   := $(FT_STAGINGDIR)
FT_DESTPFX   := $(FT_DESTDIR)$(FT_PREFIX)
FT_LDFLAGS   := -L$(FT_DESTPFX)/lib -Wl,-rpath-link=$(FT_DESTPFX)/lib -Wl,-rpath=$(FT_PREFIX)/lib

export PATH  := /opt/aarch64--musl--stable-2025.08-1/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin

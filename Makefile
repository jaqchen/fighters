#
# Copyright 2021 Ye Holmes <yeholmes@outlook.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MAKEFLAGS += -r -R # Disable builtin variables and rules

# Setup build environment for fighters project
export FT_TOPDIR      :=$(CURDIR)
export FT_OUTDIR      :=$(FT_TOPDIR)/output
export FT_STAGINGDIR  :=$(FT_OUTDIR)/staging_dir
export FT_MAKEDIR     :=$(FT_TOPDIR)/include
export FT_PKGSDIR     :=$(FT_TOPDIR)/packages
export FT_PKGINC      :=$(FT_TOPDIR)/.build-cfg.mk
export FT_PKGCOMMON   :=$(FT_MAKEDIR)/ftpkg-common.mk

# check whether CURDIR has whitespaces:
ifneq "$(words $(FT_TOPDIR))" "1"
$(error Error, whitespaces found in current directory)
endif

# Configuration file for fighters project
FT_BOARDDIR           :=$(FT_TOPDIR)/boards
FT_BASECFG            :=$(FT_TOPDIR)/.pkgs-cfg.mk
FT_GENCONF            :=$(FT_OUTDIR)/ftpkg-gen.mk

include $(FT_MAKEDIR)/rules.mk

# packages to compiled and installed:
FT_BPKGS :=
FT_BPKGS_COMPILE = $(addsuffix /$(FT_TCOMPILED),$(FT_BPKGS))

.PHONY: all clean distclean %/defconfig
.SECONDEXPANSION:
all: | $$(FT_BPKGS_COMPILE)
.NOTPARALLEL:
all: $(FT_GENCONF)
	@echo "All packages successfully compiled."
-include $(FT_GENCONF)
# strip white spaces in `FT_BPKGS:
# FT_BPKGS := $(strip $(FT_BPKGS))
$(FT_GENCONF): | $(FT_OUTDIR) $(FT_STAGINGDIR)
$(FT_GENCONF): $(FT_BASECFG) $(FT_TOPDIR)/packages/ftpkgs.mk
	@$(MAKE) -f $(FT_MAKEDIR)/pkgs-generate.mk FTPKG_IN=$< FTPKG_OUT=$@ all
$(FT_OUTDIR) $(FT_STAGINGDIR):
	@mkdir -v -p $@
clean: $(foreach ftpkg,$(FT_BPKGS),$(ftpkg)/clean)
	@echo "All packages successfully cleaned."
distclean: clean
	@rm -v -rf $(FT_BASECFG) $(FT_GENCONF) $(FT_BUILDCFG)
	@rm -rf $(FT_OUTDIR)
# Note that `defconfig should be an executable shell script:
%/defconfig: $(FT_BOARDDIR)/%/defconfig
	@echo "Configuring for board: $*"
	@cd $(FT_BOARDDIR)/$*/ && exec sh ./defconfig
$(foreach ftpkg,$(FT_BPKGS),$(eval $(call ftpkg_clean,$(ftpkg))))
$(foreach ftpkg,$(FT_BPKGS),$(eval $(call ftpkg_compile,$(ftpkg))))
$(foreach ftpkg,$(FT_BPKGS),$(eval $(call ftpkg_prepare,$(ftpkg))))

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

ifndef FIGHTER_RULES_INCLUDED
FIGHTER_RULES_INCLUDED :=yes

FT_TCOMPILED       :=.ft-compiled
FT_TPREPARED       :=.ft-prepared
FT_MAKEFILE        :=ftpkg.mk
FT_MAKEJOBS        :=$(if $(FTJOBS),-j$(FTJOBS))

.PHONY: %/fbuild
%/fbuild %/$(FT_TCOMPILED): %/$(FT_TPREPARED)
	@$(MAKE) $(FT_MAKEJOBS) -C $* -f $(FT_MAKEFILE) compile
	@$(MAKE) $(FT_MAKEJOBS) -C $* -f $(FT_MAKEFILE) install
	@touch $*/$(FT_TCOMPILED)
%/$(FT_TPREPARED): %/$(FT_MAKEFILE)
	@$(MAKE) -C $* -f $(FT_MAKEFILE) prepare
	@touch $@
define ftpkg_compile
.PHONY: $1/compile
$1/compile: $1/$$(FT_TCOMPILED)
endef

define ftpkg_prepare
.PHONY: $1/prepare
$1/prepare: $1/$$(FT_TPREPARED)
endef

define ftpkg_clean
.PHONY: $1/clean
$1/clean:
	-@$$(MAKE) -C $1 -f $$(FT_MAKEFILE) clean
	@rm -v -f $1/$$(FT_TCOMPILED) $1/$$(FT_TPREPARED)
endef

endif # END OF FIGHTER_RULES_INCLUDED

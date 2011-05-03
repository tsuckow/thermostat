.SUFFIXES:            # Delete the default suffixes

PATH += :/home/Deathbob/toolchain/toolchain-out/bin

CROSS_COMPILE = or32-linux-
CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++
LD = $(CROSS_COMPILE)ld
NM = $(CROSS_COMPILE)nm
OBJDUMP = $(CROSS_COMPILE)objdump
OBJCOPY = $(CROSS_COMPILE)objcopy
AR = $(CROSS_COMPILE)ar

### Build flags for all targets
#
CF_ALL          = -g -c -Wunknown-pragmas -mhard-mul -mhard-div -msoft-float -O3 -I fs/inc
LF_ALL          = -Bstatic -static --stats -L $(LIBPATH)
LL_ALL          = -lstdc++
COMPLINK = $(CXX) $(CF_ALL) $(CF_TGT) $(LF_ALL) $(LF_TGT) -o $@ $< $(LL_TGT) $(LL_ALL)

LIBPATH = /home/Deathbob/toolchain/toolchain-out/or32-linux/lib

.PHONY: all
all: realall

null :=
space := ${null} ${null}
# ${ } is a space. Neat huh?
${space} := ${space}

#newline
define \n


endef

#
# SPECIAL MAKEFILE FUNCTIONS
#

sp :=
d  :=
TGT_BIN :=
CLEAN :=

define incdir_template
sp              := $$(sp).x
dirstack_$$(sp) := $$d
d               := $1

include  $$d/Makedir
-include $$(DEPS_$$d)

d               := $$(dirstack_$$(sp))
sp              := $$(basename $$(sp))
endef
incdir = $(eval $(call incdir_template,$1))

define buildexe_template

ifndef 2
$$(error buildexe> No Sources Specified)
endif

#We could clean paths with abspath but it would be more complicated
TGT_SRC := $$(addprefix $$d/,$2)

TGTS_$$d	:= $$(d)/$1
DEPS_$$d	:= $$(TGTS_$$d:%=%.d) $$(addsuffix .d,$$(TGT_SRC))

TGT_BIN		:= $$(TGT_BIN) $$(TGTS_$$d)
CLEAN		:= $$(CLEAN) $$(TGTS_$$d) $$(TGTS_$$d).map $$(DEPS_$d) $$(filter %.o,$$(TGT_SRC))

$$(TGTS_$$d):	$$d/Makedir

$$(TGTS_$$d):	CF_TGT := $3
$$(TGTS_$$d):	LL_TGT := $4
$$(TGTS_$$d):	TGT_SRC := $$(TGT_SRC)
$$(TGTS_$$d):	$$(TGT_SRC) ram.ld $5
	$$(LD) -Tram.ld -Map $1.map $$(LF_ALL) $$(LF_TGT) -o $$@ $$(TGT_SRC) $$(LL_TGT) $$(LL_ALL)
	$$(OBJDUMP) -x -d -S $$@ >> $1.map
endef
#buildexe(exename,sources,CFLAGS,LLibraries,Dependancies)
buildexe = $(eval $(call buildexe_template,$1,$2,$3,$4,$5))

define builda_template

ifndef 2
$$(error builda> No Sources Specified)
endif

#We could clean paths with abspath but it would be more complicated
TGT_SRC     := $$(addprefix $$d/,$2)

TGTS_$$d	:= $$(d)/$1
DEPS_$$d	:= $$(TGTS_$$d:%=%.d) $$(addsuffix .d,$$(TGT_SRC))

TGT_BIN		:= $$(TGT_BIN) $$(TGTS_$$d)
CLEAN		:= $$(CLEAN) $$(TGTS_$$d) $$(TGTS_$$d).map $$(DEPS_$d) $$(filter %.o,$$(TGT_SRC))

$$(TGTS_$$d):	$$d/Makedir
$$(TGTS_$$d):	TGT_SRC := $$(TGT_SRC)
$$(TGTS_$$d):	$$(TGT_SRC)
	$(AR) rcs $$@ $$(TGT_SRC)
endef
#builda(exename,sources)
builda = $(eval $(call builda_template,$1,$2))

lib: $(OBJ)
	

#
# END SPECIAL FUNCTIONS
#

#Include Current Directory
$(call incdir,.)
$(call incdir,fs)

%.o:%.S
	$(CC) -MD -MP -MF $@.d $(CF_ALL) -o $@ $(<)

%.o:%.c
	$(CC) -MD -MP -MF $@.d $(CF_ALL) -o $@ $(<)

%.o:%.cpp
	$(CXX) -MD -MP -MF $@.d $(CF_ALL) -o $@ $(<)

#
# The real targets
#

.PHONY: clean
clean:
	rm -f $(CLEAN)

.PHONY: realall
realall: boot.pof boot.dat $(TGT_BIN)

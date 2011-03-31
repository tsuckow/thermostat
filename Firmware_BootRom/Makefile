PATH += :/home/tsuckow/ortoolchain/toolchain/toolchain-out/bin

CROSS_COMPILE = or32-linux-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
NM = $(CROSS_COMPILE)nm
OBJ = $(CROSS_COMPILE)objdump
OBJC = $(CROSS_COMPILE)objcopy

INCLUDEPATH = /home/tsuckow/ortoolchain/toolchain/toolchain-out/or32-linux/sys-root/usr/include
LIBPATH = /home/tsuckow/ortoolchain/toolchain/uClibc/lib

CFLAGS  = -O2 -g -c -Wunknown-pragmas -mhard-mul -msoft-div -msoft-float -I $(INCLUDEPATH)
LD_FLAGS= --stats -Tram.ld -L $(LIBPATH) -lc
INCL    = board.h spr_defs.h spi.h
OBJECTS = BootReset.o main.o revision.o
LIBS    =

BOOTOBJS = main.o BootReset.o

.PHONY: all
all: boot.dat

boot.dat: boot.ihex
	perl hex2v.pl < boot.ihex > boot.dat

boot.ihex: boot.or32
	$(OBJC) -O ihex boot.or32 boot.ihex

boot.or32: $(BOOTOBJS) Makefile ram.ld
	$(LD) -Map System.map -Bstatic $(BOOTOBJS) $(LD_FLAGS) -o $@
	$(OBJ) -x -d -S $@ >> System.map

%.o:%.S
	$(CC) $(CFLAGS) -o $@ $(<)

%.o:%.c
	$(CC) $(CFLAGS) -o $@ $(<)

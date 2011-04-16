PATH += :/home/Deathbob/toolchain/toolchain-out/bin

CROSS_COMPILE = or32-linux-
CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++
LD = $(CROSS_COMPILE)ld
NM = $(CROSS_COMPILE)nm
OBJ = $(CROSS_COMPILE)objdump
OBJC = $(CROSS_COMPILE)objcopy

LIBPATH = /home/Deathbob/toolchain/toolchain-out/or32-linux/lib

CFLAGS  = -g -c -Wunknown-pragmas -mhard-mul -msoft-div -msoft-float -O3
LD_FLAGS= --stats -Tram.ld -L $(LIBPATH) -lstdc++
INCL    = test.h spr_defs.h touchscreen.h
LIBS    =

BOOTOBJS = main.o BootReset.o test.o touchscreen.o exception.o

.PHONY: all
all: boot.dat

boot.dat: boot.ihex
	perl hex2v.pl < boot.ihex > boot.dat

boot.ihex: boot.or32
	$(OBJC) -O ihex boot.or32 boot.ihex

boot.or32: $(BOOTOBJS) Makefile ram.ld $(INCL)
	$(LD) -Map System.map -Bstatic $(BOOTOBJS) $(LD_FLAGS) -o $@
	$(OBJ) -x -d -S $@ >> System.map

%.o:%.S
	$(CC) $(CFLAGS) -o $@ $(<)

%.o:%.c
	$(CC) $(CFLAGS) -o $@ $(<)

%.o:%.cpp
	$(CXX) $(CFLAGS) -o $@ $(<)

.PHONY: clean
clean:
	-rm *.o
	-rm *.ihex
	-rm *.or32
	-rm *.dat

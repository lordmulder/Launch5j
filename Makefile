############################################################
# Launch5j, by LoRd_MuldeR <MuldeR2@GMX.de>                #
# Java JAR wrapper for creating Windows native executables #
# https://github.com/lordmulder/                           #
#                                                          #
# This work has been released under the MIT license.       #
# Please see LICENSE.TXT for details!                      #
#                                                          #
# ACKNOWLEDGEMENT                                          #
# This project is partly inspired by the Launch4j project: #
# https://sourceforge.net/p/launch4j/                      #
############################################################

ifeq ($(words $(filter x86_64-%,$(shell $(CXX) -dumpmachine))),0)
  CPU_ARCH := i586
else
  CPU_ARCH := x86-64
endif

MARCH ?= $(CPU_ARCH)
MTUNE ?= generic

CFLAGS = -Os -static -municode -mwindows -march=$(MARCH) -mtune=$(MTUNE)

.PHONY: all init resources build strip clean

all: strip

init:
	mkdir -p bin
	mkdir -p obj

resources: init
	windres -o obj/common.$(CPU_ARCH).o res/common.rc
	windres -o obj/splash_screen.$(CPU_ARCH).o res/splash_screen.rc
	windres -o obj/registry.$(CPU_ARCH).o res/registry.rc

build: init resources
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=0 -DDETECT_REGISTRY=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH).exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=0 -DDETECT_REGISTRY=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=0 -DDETECT_REGISTRY=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=0 -DDETECT_REGISTRY=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=0 -DDETECT_REGISTRY=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=0 -DDETECT_REGISTRY=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=0 -DDETECT_REGISTRY=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=0 -DDETECT_REGISTRY=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=1 -DDETECT_REGISTRY=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=1 -DDETECT_REGISTRY=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=1 -DDETECT_REGISTRY=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=1 -DDETECT_REGISTRY=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=1 -DDETECT_REGISTRY=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=1 -DDETECT_REGISTRY=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=1 -DDETECT_REGISTRY=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DJAR_FILE_WRAPPED=1 -DDETECT_REGISTRY=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o

strip: build
	strip bin/launch5j_$(CPU_ARCH).exe
	strip bin/launch5j_$(CPU_ARCH)_nosplash.exe
	strip bin/launch5j_$(CPU_ARCH)_nowait.exe
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe
	strip bin/launch5j_$(CPU_ARCH)_registry.exe
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait.exe
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe
	strip bin/launch5j_$(CPU_ARCH)_wrapped.exe
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe

clean: init
	rm -f bin/*.exe
	rm -f obj/*.o


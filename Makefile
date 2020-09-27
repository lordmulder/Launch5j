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
  EXE_ARCH = x86
  DEFAULT_MARCH := i586
else
  EXE_ARCH = x64
  DEFAULT_MARCH := x86-64
endif

MARCH ?= $(DEFAULT_MARCH)
MTUNE ?= generic

CFLAGS = -Os -static -municode -mwindows -march=$(MARCH) -mtune=$(MTUNE)

.PHONY: all init resources build strip clean

all: strip

init:
	mkdir -p bin
	mkdir -p obj

resources: init
	windres -o obj/icon.$(EXE_ARCH).o          res/icon.rc
	windres -o obj/splash_screen.$(EXE_ARCH).o res/splash_screen.rc
	windres -o obj/version.$(EXE_ARCH).o       res/version.rc

build: init resources
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).exe                                         -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).nosplash.exe                                -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).nowait.exe                                  -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).nowait_nosplash.exe                         -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).wrapped.exe                                 -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).wrapped_nosplash.exe                        -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).wrapped_nowait.exe                          -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).wrapped_nowait_nosplash.exe                 -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry.exe                                -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_nosplash.exe                       -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_nowait.exe                         -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_nowait_nosplash.exe                -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_wrapped.exe                        -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_wrapped_nosplash.exe               -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_wrapped_nowait.exe                 -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_wrapped_nowait_nosplash.exe        -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_java11.exe                         -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_java11_nosplash.exe                -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_java11_nowait.exe                  -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_java11_nowait_nosplash.exe         -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_java11_wrapped.exe                 -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_java11_wrapped_nosplash.exe        -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_java11_wrapped_nowait.exe          -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o obj/splash_screen.$(EXE_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(EXE_ARCH).registry_java11_wrapped_nowait_nosplash.exe -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(EXE_ARCH).o obj/icon.$(EXE_ARCH).o

strip: build
	find bin -type f -name '*.exe' -exec strip -v {} \;

clean: init
	rm -f bin/*.exe
	rm -f obj/*.o

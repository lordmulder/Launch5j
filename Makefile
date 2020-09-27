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

MTUNE ?= generic
OS_TYPE := $(shell $(CXX) -dumpmachine)

ifeq ($(words $(filter x86_64-%,$(OS_TYPE))),0)
  MARCH ?= i586
  L5J_ARCH = x86
else
  MARCH ?= x86-64
  L5J_ARCH = x64
endif

CFLAGS = -Os -static -municode -mwindows -march=$(MARCH) -mtune=$(MTUNE)

.PHONY: all init headers resources clean

all: headers

init:
	mkdir -p bin
	mkdir -p obj

resources: init
	windres -o obj/icon.$(L5J_ARCH).o          res/icon.rc
	windres -o obj/splash_screen.$(L5J_ARCH).o res/splash_screen.rc
	windres -o obj/version.$(L5J_ARCH).o       res/version.rc

headers: init resources
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).exe                                         -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).nosplash.exe                                -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).nowait.exe                                  -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).nowait_nosplash.exe                         -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).wrapped.exe                                 -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).wrapped_nosplash.exe                        -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).wrapped_nowait.exe                          -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).wrapped_nowait_nosplash.exe                 -DDETECT_REGISTRY=0 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry.exe                                -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_nosplash.exe                       -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_nowait.exe                         -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_nowait_nosplash.exe                -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_wrapped.exe                        -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_wrapped_nosplash.exe               -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_wrapped_nowait.exe                 -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_wrapped_nowait_nosplash.exe        -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_java11.exe                         -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_java11_nosplash.exe                -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_java11_nowait.exe                  -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_java11_nowait_nosplash.exe         -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_java11_wrapped.exe                 -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_java11_wrapped_nosplash.exe        -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_java11_wrapped_nowait.exe          -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o obj/splash_screen.$(L5J_ARCH).o
	$(CC) $(CFLAGS) -o bin/launch5j_$(L5J_ARCH).registry_java11_wrapped_nowait_nosplash.exe -DDETECT_REGISTRY=1 -DREQUIRE_JAVA11=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/version.$(L5J_ARCH).o obj/icon.$(L5J_ARCH).o
	strip bin/launch5j_$(L5J_ARCH).exe
	strip bin/launch5j_$(L5J_ARCH).nosplash.exe
	strip bin/launch5j_$(L5J_ARCH).nowait.exe
	strip bin/launch5j_$(L5J_ARCH).nowait_nosplash.exe
	strip bin/launch5j_$(L5J_ARCH).wrapped.exe
	strip bin/launch5j_$(L5J_ARCH).wrapped_nosplash.exe
	strip bin/launch5j_$(L5J_ARCH).wrapped_nowait.exe
	strip bin/launch5j_$(L5J_ARCH).wrapped_nowait_nosplash.exe
	strip bin/launch5j_$(L5J_ARCH).registry.exe
	strip bin/launch5j_$(L5J_ARCH).registry_nosplash.exe
	strip bin/launch5j_$(L5J_ARCH).registry_nowait.exe
	strip bin/launch5j_$(L5J_ARCH).registry_nowait_nosplash.exe
	strip bin/launch5j_$(L5J_ARCH).registry_wrapped.exe
	strip bin/launch5j_$(L5J_ARCH).registry_wrapped_nosplash.exe
	strip bin/launch5j_$(L5J_ARCH).registry_wrapped_nowait.exe
	strip bin/launch5j_$(L5J_ARCH).registry_wrapped_nowait_nosplash.exe
	strip bin/launch5j_$(L5J_ARCH).registry_java11.exe
	strip bin/launch5j_$(L5J_ARCH).registry_java11_nosplash.exe
	strip bin/launch5j_$(L5J_ARCH).registry_java11_nowait.exe
	strip bin/launch5j_$(L5J_ARCH).registry_java11_nowait_nosplash.exe
	strip bin/launch5j_$(L5J_ARCH).registry_java11_wrapped.exe
	strip bin/launch5j_$(L5J_ARCH).registry_java11_wrapped_nosplash.exe
	strip bin/launch5j_$(L5J_ARCH).registry_java11_wrapped_nowait.exe
	strip bin/launch5j_$(L5J_ARCH).registry_java11_wrapped_nowait_nosplash.exe

clean: init
	rm -f bin/*.exe
	rm -f obj/*.o

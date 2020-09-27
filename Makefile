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

MARCH ?= i586
MTUNE ?= intel

CFLAGS = -O3 -municode -mwindows -march=$(MARCH) -mtune=$(MTUNE)

.PHONY: all init headers resources clean

all: headers

init:
	mkdir -p bin
	mkdir -p obj

resources: init
	windres -o obj/icon.o          res/icon.rc
	windres -o obj/splash_screen.o res/splash_screen.rc

headers: init resources
	$(CC) $(CFLAGS) -o bin/head.exe                                  -DDETECT_REGISTRY=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/icon.o obj/splash_screen.o
	$(CC) $(CFLAGS) -o bin/head_nosplash.exe                         -DDETECT_REGISTRY=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/icon.o
	$(CC) $(CFLAGS) -o bin/head_nowait.exe                           -DDETECT_REGISTRY=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/icon.o obj/splash_screen.o
	$(CC) $(CFLAGS) -o bin/head_nowait_nosplash.exe                  -DDETECT_REGISTRY=0 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/icon.o
	$(CC) $(CFLAGS) -o bin/head_wrapped.exe                          -DDETECT_REGISTRY=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/icon.o obj/splash_screen.o
	$(CC) $(CFLAGS) -o bin/head_wrapped_nosplash.exe                 -DDETECT_REGISTRY=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/icon.o
	$(CC) $(CFLAGS) -o bin/head_wrapped_nowait.exe                   -DDETECT_REGISTRY=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/icon.o obj/splash_screen.o
	$(CC) $(CFLAGS) -o bin/head_wrapped_nowait_nosplash.exe          -DDETECT_REGISTRY=0 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/icon.o
	$(CC) $(CFLAGS) -o bin/head_registry.exe                         -DDETECT_REGISTRY=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/icon.o obj/splash_screen.o
	$(CC) $(CFLAGS) -o bin/head_registry_nosplash.exe                -DDETECT_REGISTRY=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/icon.o
	$(CC) $(CFLAGS) -o bin/head_registry_nowait.exe                  -DDETECT_REGISTRY=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/icon.o obj/splash_screen.o
	$(CC) $(CFLAGS) -o bin/head_registry_nowait_nosplash.exe         -DDETECT_REGISTRY=1 -DJAR_FILE_WRAPPED=0 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/icon.o
	$(CC) $(CFLAGS) -o bin/head_registry_wrapped.exe                 -DDETECT_REGISTRY=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=1 src/head.c obj/icon.o obj/splash_screen.o
	$(CC) $(CFLAGS) -o bin/head_registry_wrapped_nosplash.exe        -DDETECT_REGISTRY=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=1 -DENABLE_SPLASH=0 src/head.c obj/icon.o
	$(CC) $(CFLAGS) -o bin/head_registry_wrapped_nowait.exe          -DDETECT_REGISTRY=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=1 src/head.c obj/icon.o obj/splash_screen.o
	$(CC) $(CFLAGS) -o bin/head_registry_wrapped_nowait_nosplash.exe -DDETECT_REGISTRY=1 -DJAR_FILE_WRAPPED=1 -DSTAY_ALIVE=0 -DENABLE_SPLASH=0 src/head.c obj/icon.o
	strip bin/head.exe
	strip bin/head_nosplash.exe
	strip bin/head_nowait.exe
	strip bin/head_nowait_nosplash.exe
	strip bin/head_wrapped.exe
	strip bin/head_wrapped_nosplash.exe
	strip bin/head_wrapped_nowait.exe
	strip bin/head_wrapped_nowait_nosplash.exe
	strip bin/head_registry.exe
	strip bin/head_registry_nosplash.exe
	strip bin/head_registry_nowait.exe
	strip bin/head_registry_nowait_nosplash.exe
	strip bin/head_registry_wrapped.exe
	strip bin/head_registry_wrapped_nosplash.exe
	strip bin/head_registry_wrapped_nowait.exe
	strip bin/head_registry_wrapped_nowait_nosplash.exe

clean: init
	rm -f bin/*.exe
	rm -f obj/*.o

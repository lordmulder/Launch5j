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

MACHINE := $(patsubst %-w64-mingw32,[%],$(shell $(CXX) -dumpmachine))

ifeq ($(MACHINE),[i686])
  CPU_ARCH := x86
  MARCH ?= i586
else ifeq ($(MACHINE),[x86_64])
  CPU_ARCH := x64
  MARCH ?= x86-64
else
  $(error Unknown target machine "$(MACHINE)" encountered!)
endif

DEBUG ?= 0
MTUNE ?= generic

ifeq ($(DEBUG),0)
  CFLAGS = -Os -static -static-libgcc -D_FORTIFY_SOURCE=2 -DNDEBUG
  SUFFIX = exe
else
  CFLAGS =  -Og -g
  SUFFIX = g.exe
endif

CFLAGS += -municode -mwindows -march=$(MARCH) -mtune=$(MTUNE)
LDFLAGS = -lcomctl32

.PHONY: all init resources build strip clean

ifeq ($(DEBUG),0)
all: strip
else
all: build
endif

init:
	mkdir -p bin
	mkdir -p obj

resources: init
	windres -o obj/common.$(CPU_ARCH).o res/common.rc
	windres -o obj/splash_screen.$(CPU_ARCH).o res/splash_screen.rc
	windres -o obj/registry.$(CPU_ARCH).o res/registry.rc

build: init resources
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH).exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)

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
	$(RM) bin/*.$(SUFFIX)
	$(RM) obj/*.o


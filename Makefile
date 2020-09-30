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
	echo $(OS)
	windres -o obj/common.$(CPU_ARCH).o res/common.rc
	windres -o obj/splash_screen.$(CPU_ARCH).o res/splash_screen.rc
	windres -o obj/registry.$(CPU_ARCH).o res/registry.rc

build: init resources
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH).$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_nosplash.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_nowait.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_registry.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
	$(CC) $(CFLAGS) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.$(SUFFIX) src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o

strip: build
	strip bin/launch5j_$(CPU_ARCH).$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_nosplash.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_nowait.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_registry.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_wrapped.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.$(SUFFIX)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.$(SUFFIX)

clean: init
	$(RM) bin/*.$(SUFFIX)
	$(RM) obj/*.o

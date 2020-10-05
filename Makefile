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
BUILDNO := $(shell git rev-list --count HEAD 2>&- || echo 0)

VERSION_MAJOR := $(shell grep -Po '#define[[:space:]]+L5J_VERSION_MAJOR[[:space:]]+\K[[:digit:]]+' src/resource.h)
VERSION_MINOR := $(shell grep -Po '#define[[:space:]]+L5J_VERSION_MINOR[[:space:]]+\K[[:digit:]]+' src/resource.h)
VERSION_PATCH := $(shell grep -Po '#define[[:space:]]+L5J_VERSION_PATCH[[:space:]]+\K[[:digit:]]+' src/resource.h)

ifeq ($(MACHINE),[i686])
  CPU_ARCH := x86
  MARCH ?= i586
else ifeq ($(MACHINE),[x86_64])
  CPU_ARCH := amd64
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

CFLAGS += -municode -march=$(MARCH) -mtune=$(MTUNE)

# ==========================================================
# Targets
# ==========================================================

.PHONY: default
default: all

.PHONY: initialize
initialize:
	mkdir -p bin
	mkdir -p obj
	mkdir -p tmp

.PHONY: manifests
manifests: initialize
	@mkdir -p tmp/assets
	sed -e 's/$${{version}}/$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH).$(BUILDNO)/g' -e 's/$${{processorArchitecture}}/$(CPU_ARCH)/g' res/assets/manifest-console.xml > tmp/assets/manifest-console.$(CPU_ARCH).xml
	sed -e 's/$${{version}}/$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH).$(BUILDNO)/g' -e 's/$${{processorArchitecture}}/$(CPU_ARCH)/g' res/assets/manifest-windows.xml > tmp/assets/manifest-windows.$(CPU_ARCH).xml

.PHONY: resources
resources: manifests
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/common.$(CPU_ARCH).o res/common.rc
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/manifest-console.$(CPU_ARCH).o  res/manifest-console.rc
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/manifest-windows.$(CPU_ARCH).o  res/manifest-windows.rc
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/registry.$(CPU_ARCH).o res/registry.rc
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/splash_screen.$(CPU_ARCH).o res/splash_screen.rc

.PHONY: clean
clean: initialize
	find bin -type f -delete
	find obj -type f -delete
	find tmp -type f -delete

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Binaries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: launch5j_B855
launch5j_B855: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH).exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH).exe
endif

.PHONY: launch5j_A2FE
launch5j_A2FE: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_noenc.exe
endif

.PHONY: launch5j_D99E
launch5j_D99E: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash.exe
endif

.PHONY: launch5j_6DCE
launch5j_6DCE: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe
endif

.PHONY: launch5j_9E54
launch5j_9E54: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait.exe
endif

.PHONY: launch5j_1CDC
launch5j_1CDC: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe
endif

.PHONY: launch5j_459A
launch5j_459A: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe
endif

.PHONY: launch5j_AA99
launch5j_AA99: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe
endif

.PHONY: launch5j_2F4C
launch5j_2F4C: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry.exe
endif

.PHONY: launch5j_1A0D
launch5j_1A0D: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_noenc.exe
endif

.PHONY: launch5j_9AA2
launch5j_9AA2: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe
endif

.PHONY: launch5j_7178
launch5j_7178: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe
endif

.PHONY: launch5j_A25D
launch5j_A25D: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait.exe
endif

.PHONY: launch5j_20DF
launch5j_20DF: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe
endif

.PHONY: launch5j_8568
launch5j_8568: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe
endif

.PHONY: launch5j_2BCA
launch5j_2BCA: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe
endif

.PHONY: launch5j_7B70
launch5j_7B70: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped.exe
endif

.PHONY: launch5j_91AC
launch5j_91AC: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe
endif

.PHONY: launch5j_FA0C
launch5j_FA0C: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe
endif

.PHONY: launch5j_2559
launch5j_2559: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe
endif

.PHONY: launch5j_2EFE
launch5j_2EFE: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe
endif

.PHONY: launch5j_8F9C
launch5j_8F9C: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe
endif

.PHONY: launch5j_3478
launch5j_3478: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe
endif

.PHONY: launch5j_4F5B
launch5j_4F5B: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe
endif

.PHONY: launch5j_2A1E
launch5j_2A1E: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe
endif

.PHONY: launch5j_FE04
launch5j_FE04: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe
endif

.PHONY: launch5j_2BCE
launch5j_2BCE: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe
endif

.PHONY: launch5j_9D63
launch5j_9D63: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe
endif

.PHONY: launch5j_F5D7
launch5j_F5D7: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe
endif

.PHONY: launch5j_33A4
launch5j_33A4: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe
endif

.PHONY: launch5j_D3FD
launch5j_D3FD: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe
endif

.PHONY: launch5j_D36F
launch5j_D36F: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe
endif

.PHONY: launch5j_F945
launch5j_F945: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui.exe
endif

.PHONY: launch5j_4745
launch5j_4745: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_noenc.exe
endif

.PHONY: launch5j_01E0
launch5j_01E0: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_nowait.exe
endif

.PHONY: launch5j_78AA
launch5j_78AA: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_nowait_noenc.exe
endif

.PHONY: launch5j_B8C6
launch5j_B8C6: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry.exe
endif

.PHONY: launch5j_3848
launch5j_3848: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry_noenc.exe
endif

.PHONY: launch5j_778B
launch5j_778B: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait.exe
endif

.PHONY: launch5j_627C
launch5j_627C: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait_noenc.exe
endif

.PHONY: launch5j_66EE
launch5j_66EE: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped.exe
endif

.PHONY: launch5j_9FFA
launch5j_9FFA: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_noenc.exe
endif

.PHONY: launch5j_7C79
launch5j_7C79: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait.exe
endif

.PHONY: launch5j_2928
launch5j_2928: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait_noenc.exe
endif

.PHONY: launch5j_8EFD
launch5j_8EFD: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry.exe
endif

.PHONY: launch5j_59FE
launch5j_59FE: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_noenc.exe
endif

.PHONY: launch5j_C25B
launch5j_C25B: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait.exe
endif

.PHONY: launch5j_DAFA
launch5j_DAFA: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/manifest-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait_noenc.exe
endif

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: all
all: \
  launch5j_B855 \
  launch5j_A2FE \
  launch5j_D99E \
  launch5j_6DCE \
  launch5j_9E54 \
  launch5j_1CDC \
  launch5j_459A \
  launch5j_AA99 \
  launch5j_2F4C \
  launch5j_1A0D \
  launch5j_9AA2 \
  launch5j_7178 \
  launch5j_A25D \
  launch5j_20DF \
  launch5j_8568 \
  launch5j_2BCA \
  launch5j_7B70 \
  launch5j_91AC \
  launch5j_FA0C \
  launch5j_2559 \
  launch5j_2EFE \
  launch5j_8F9C \
  launch5j_3478 \
  launch5j_4F5B \
  launch5j_2A1E \
  launch5j_FE04 \
  launch5j_2BCE \
  launch5j_9D63 \
  launch5j_F5D7 \
  launch5j_33A4 \
  launch5j_D3FD \
  launch5j_D36F \
  launch5j_F945 \
  launch5j_4745 \
  launch5j_01E0 \
  launch5j_78AA \
  launch5j_B8C6 \
  launch5j_3848 \
  launch5j_778B \
  launch5j_627C \
  launch5j_66EE \
  launch5j_9FFA \
  launch5j_7C79 \
  launch5j_2928 \
  launch5j_8EFD \
  launch5j_59FE \
  launch5j_C25B \
  launch5j_DAFA


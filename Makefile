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
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -o obj/common-console.$(CPU_ARCH).o res/common.rc
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -o obj/common-windows.$(CPU_ARCH).o res/common.rc
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/splash_screen.$(CPU_ARCH).o res/splash_screen.rc
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/registry.$(CPU_ARCH).o res/registry.rc

.PHONY: clean
clean: initialize
	find bin -type f -delete
	find obj -type f -delete
	find tmp -type f -delete

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Binaries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: l5j_3408C391
l5j_3408C391: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH).exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH).exe
endif

.PHONY: l5j_7136B6DC
l5j_7136B6DC: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_noenc.exe
endif

.PHONY: l5j_A9CBE2BD
l5j_A9CBE2BD: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash.exe
endif

.PHONY: l5j_2FFF81A3
l5j_2FFF81A3: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe
endif

.PHONY: l5j_37E2DD90
l5j_37E2DD90: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait.exe
endif

.PHONY: l5j_2FF174B2
l5j_2FF174B2: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe
endif

.PHONY: l5j_A5086989
l5j_A5086989: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe
endif

.PHONY: l5j_57CF673B
l5j_57CF673B: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_D9F32FAB
l5j_D9F32FAB: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry.exe
endif

.PHONY: l5j_1DB1893C
l5j_1DB1893C: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_noenc.exe
endif

.PHONY: l5j_CF357B5F
l5j_CF357B5F: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe
endif

.PHONY: l5j_F29626A2
l5j_F29626A2: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe
endif

.PHONY: l5j_EED289B0
l5j_EED289B0: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait.exe
endif

.PHONY: l5j_42987161
l5j_42987161: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe
endif

.PHONY: l5j_00EE138C
l5j_00EE138C: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe
endif

.PHONY: l5j_58538121
l5j_58538121: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_C02E308A
l5j_C02E308A: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped.exe
endif

.PHONY: l5j_E23ED2F0
l5j_E23ED2F0: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe
endif

.PHONY: l5j_82A3B0B4
l5j_82A3B0B4: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe
endif

.PHONY: l5j_4529DCBD
l5j_4529DCBD: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe
endif

.PHONY: l5j_30FFBD22
l5j_30FFBD22: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe
endif

.PHONY: l5j_8F60BF3F
l5j_8F60BF3F: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe
endif

.PHONY: l5j_81396422
l5j_81396422: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe
endif

.PHONY: l5j_08580B94
l5j_08580B94: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_ED6E61AB
l5j_ED6E61AB: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe
endif

.PHONY: l5j_9A3A029E
l5j_9A3A029E: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe
endif

.PHONY: l5j_E9BFEAD2
l5j_E9BFEAD2: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe
endif

.PHONY: l5j_6693C2C3
l5j_6693C2C3: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe
endif

.PHONY: l5j_F367C257
l5j_F367C257: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe
endif

.PHONY: l5j_A0ECB342
l5j_A0ECB342: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe
endif

.PHONY: l5j_B40D57DA
l5j_B40D57DA: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe
endif

.PHONY: l5j_7C40A82A
l5j_7C40A82A: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_50BA8B12
l5j_50BA8B12: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui.exe
endif

.PHONY: l5j_49A8C2A3
l5j_49A8C2A3: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_noenc.exe
endif

.PHONY: l5j_FE360AA8
l5j_FE360AA8: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_nowait.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_nowait.exe
endif

.PHONY: l5j_B1DC1479
l5j_B1DC1479: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_nowait_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_nowait_noenc.exe
endif

.PHONY: l5j_3945741E
l5j_3945741E: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_registry.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry.exe
endif

.PHONY: l5j_3D82C154
l5j_3D82C154: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_registry_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry_noenc.exe
endif

.PHONY: l5j_D5C53DAC
l5j_D5C53DAC: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait.exe
endif

.PHONY: l5j_5A1AA93B
l5j_5A1AA93B: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait_noenc.exe
endif

.PHONY: l5j_18F10B52
l5j_18F10B52: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped.exe
endif

.PHONY: l5j_823D747D
l5j_823D747D: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_noenc.exe
endif

.PHONY: l5j_07336CFC
l5j_07336CFC: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait.exe
endif

.PHONY: l5j_1173C153
l5j_1173C153: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait_noenc.exe
endif

.PHONY: l5j_95FF26D5
l5j_95FF26D5: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry.exe
endif

.PHONY: l5j_3E68DF63
l5j_3E68DF63: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_noenc.exe
endif

.PHONY: l5j_A857258D
l5j_A857258D: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait.exe
endif

.PHONY: l5j_487016A6
l5j_487016A6: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait_noenc.exe
endif

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: all
all: \
  l5j_3408C391 \
  l5j_7136B6DC \
  l5j_A9CBE2BD \
  l5j_2FFF81A3 \
  l5j_37E2DD90 \
  l5j_2FF174B2 \
  l5j_A5086989 \
  l5j_57CF673B \
  l5j_D9F32FAB \
  l5j_1DB1893C \
  l5j_CF357B5F \
  l5j_F29626A2 \
  l5j_EED289B0 \
  l5j_42987161 \
  l5j_00EE138C \
  l5j_58538121 \
  l5j_C02E308A \
  l5j_E23ED2F0 \
  l5j_82A3B0B4 \
  l5j_4529DCBD \
  l5j_30FFBD22 \
  l5j_8F60BF3F \
  l5j_81396422 \
  l5j_08580B94 \
  l5j_ED6E61AB \
  l5j_9A3A029E \
  l5j_E9BFEAD2 \
  l5j_6693C2C3 \
  l5j_F367C257 \
  l5j_A0ECB342 \
  l5j_B40D57DA \
  l5j_7C40A82A \
  l5j_50BA8B12 \
  l5j_49A8C2A3 \
  l5j_FE360AA8 \
  l5j_B1DC1479 \
  l5j_3945741E \
  l5j_3D82C154 \
  l5j_D5C53DAC \
  l5j_5A1AA93B \
  l5j_18F10B52 \
  l5j_823D747D \
  l5j_07336CFC \
  l5j_1173C153 \
  l5j_95FF26D5 \
  l5j_3E68DF63 \
  l5j_A857258D \
  l5j_487016A6


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
	mkdir -p $(@D)
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

.PHONY: l5j_AC5E0F7B
l5j_AC5E0F7B: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH).exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH).exe
endif

.PHONY: l5j_D3650C28
l5j_D3650C28: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_noenc.exe
endif

.PHONY: l5j_07E2C001
l5j_07E2C001: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash.exe
endif

.PHONY: l5j_1A7CF93E
l5j_1A7CF93E: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe
endif

.PHONY: l5j_E528C43C
l5j_E528C43C: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait.exe
endif

.PHONY: l5j_F3DBFECB
l5j_F3DBFECB: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe
endif

.PHONY: l5j_3714ED45
l5j_3714ED45: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe
endif

.PHONY: l5j_8EB7DCEA
l5j_8EB7DCEA: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_A6ADF807
l5j_A6ADF807: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry.exe
endif

.PHONY: l5j_FD9D0A03
l5j_FD9D0A03: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_noenc.exe
endif

.PHONY: l5j_715A4611
l5j_715A4611: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe
endif

.PHONY: l5j_2342BF21
l5j_2342BF21: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe
endif

.PHONY: l5j_CA4AEEEE
l5j_CA4AEEEE: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait.exe
endif

.PHONY: l5j_CD6A91A5
l5j_CD6A91A5: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe
endif

.PHONY: l5j_9112B169
l5j_9112B169: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe
endif

.PHONY: l5j_0BF455CD
l5j_0BF455CD: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_A92217A7
l5j_A92217A7: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped.exe
endif

.PHONY: l5j_5C289D36
l5j_5C289D36: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe
endif

.PHONY: l5j_E2BC6FC3
l5j_E2BC6FC3: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe
endif

.PHONY: l5j_F8FAA925
l5j_F8FAA925: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe
endif

.PHONY: l5j_BD28CD8F
l5j_BD28CD8F: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe
endif

.PHONY: l5j_3B402EED
l5j_3B402EED: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe
endif

.PHONY: l5j_E3F9AD8D
l5j_E3F9AD8D: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe
endif

.PHONY: l5j_66F05454
l5j_66F05454: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_33F9ED38
l5j_33F9ED38: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe
endif

.PHONY: l5j_5E944098
l5j_5E944098: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe
endif

.PHONY: l5j_94CDE204
l5j_94CDE204: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe
endif

.PHONY: l5j_7A0A8164
l5j_7A0A8164: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe
endif

.PHONY: l5j_C5E0DAF5
l5j_C5E0DAF5: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe
endif

.PHONY: l5j_4ABEF3E6
l5j_4ABEF3E6: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe
endif

.PHONY: l5j_F7A60AA5
l5j_F7A60AA5: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe
endif

.PHONY: l5j_AA445906
l5j_AA445906: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe src/head.c obj/common-windows.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o -lcomctl32
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_E5119C07
l5j_E5119C07: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui.exe
endif

.PHONY: l5j_05FC33A2
l5j_05FC33A2: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_noenc.exe
endif

.PHONY: l5j_FD1A2285
l5j_FD1A2285: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_nowait.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_nowait.exe
endif

.PHONY: l5j_0A8603AF
l5j_0A8603AF: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_nowait_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_nowait_noenc.exe
endif

.PHONY: l5j_04592BD0
l5j_04592BD0: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_registry.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry.exe
endif

.PHONY: l5j_CF815DD1
l5j_CF815DD1: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_registry_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry_noenc.exe
endif

.PHONY: l5j_15FAE2C7
l5j_15FAE2C7: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait.exe
endif

.PHONY: l5j_5256A700
l5j_5256A700: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_registry_nowait_noenc.exe
endif

.PHONY: l5j_735DFE78
l5j_735DFE78: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped.exe
endif

.PHONY: l5j_4897DF6D
l5j_4897DF6D: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_noenc.exe
endif

.PHONY: l5j_C11CE462
l5j_C11CE462: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait.exe
endif

.PHONY: l5j_00128557
l5j_00128557: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_nowait_noenc.exe
endif

.PHONY: l5j_7B89D793
l5j_7B89D793: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry.exe
endif

.PHONY: l5j_B07DBB1C
l5j_B07DBB1C: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_noenc.exe
endif

.PHONY: l5j_ABA57DBA
l5j_ABA57DBA: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait.exe
endif

.PHONY: l5j_20B99C28
l5j_20B99C28: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait_noenc.exe src/head.c obj/common-console.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nogui_wrapped_registry_nowait_noenc.exe
endif

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: all
all: \
  l5j_AC5E0F7B \
  l5j_D3650C28 \
  l5j_07E2C001 \
  l5j_1A7CF93E \
  l5j_E528C43C \
  l5j_F3DBFECB \
  l5j_3714ED45 \
  l5j_8EB7DCEA \
  l5j_A6ADF807 \
  l5j_FD9D0A03 \
  l5j_715A4611 \
  l5j_2342BF21 \
  l5j_CA4AEEEE \
  l5j_CD6A91A5 \
  l5j_9112B169 \
  l5j_0BF455CD \
  l5j_A92217A7 \
  l5j_5C289D36 \
  l5j_E2BC6FC3 \
  l5j_F8FAA925 \
  l5j_BD28CD8F \
  l5j_3B402EED \
  l5j_E3F9AD8D \
  l5j_66F05454 \
  l5j_33F9ED38 \
  l5j_5E944098 \
  l5j_94CDE204 \
  l5j_7A0A8164 \
  l5j_C5E0DAF5 \
  l5j_4ABEF3E6 \
  l5j_F7A60AA5 \
  l5j_AA445906 \
  l5j_E5119C07 \
  l5j_05FC33A2 \
  l5j_FD1A2285 \
  l5j_0A8603AF \
  l5j_04592BD0 \
  l5j_CF815DD1 \
  l5j_15FAE2C7 \
  l5j_5256A700 \
  l5j_735DFE78 \
  l5j_4897DF6D \
  l5j_C11CE462 \
  l5j_00128557 \
  l5j_7B89D793 \
  l5j_B07DBB1C \
  l5j_ABA57DBA \
  l5j_20B99C28


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

CFLAGS += -municode -mwindows -march=$(MARCH) -mtune=$(MTUNE)
LDFLAGS = -lcomctl32

# ==========================================================
# Targets
# ==========================================================

.PHONY: default
default: all

.PHONY: init
init:
	mkdir -p bin
	mkdir -p obj

.PHONY: resources
resources: init
	sed -e 's/$${{version}}/$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH).$(BUILDNO)/g' -e 's/$${{processorArchitecture}}/$(CPU_ARCH)/g' res/assets/manifest.xml > res/assets/manifest.$(CPU_ARCH).xml
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/common.$(CPU_ARCH).o res/common.rc
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/splash_screen.$(CPU_ARCH).o res/splash_screen.rc
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/registry.$(CPU_ARCH).o res/registry.rc

.PHONY: clean
clean: init
	$(RM) bin/*.$(SUFFIX)
	$(RM) obj/*.o

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Binaries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: l5j_9F20B84D
l5j_9F20B84D: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH).exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH).exe
endif

.PHONY: l5j_6EB7DACE
l5j_6EB7DACE: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_noenc.exe
endif

.PHONY: l5j_F5B13FCD
l5j_F5B13FCD: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash.exe
endif

.PHONY: l5j_4739563B
l5j_4739563B: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe
endif

.PHONY: l5j_6E959748
l5j_6E959748: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait.exe
endif

.PHONY: l5j_2E20373E
l5j_2E20373E: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe
endif

.PHONY: l5j_9FDC0678
l5j_9FDC0678: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe
endif

.PHONY: l5j_4CA6A4DC
l5j_4CA6A4DC: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_F2F69A4A
l5j_F2F69A4A: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry.exe
endif

.PHONY: l5j_D4F4011F
l5j_D4F4011F: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_noenc.exe
endif

.PHONY: l5j_11C4FEF5
l5j_11C4FEF5: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe
endif

.PHONY: l5j_6BE922C9
l5j_6BE922C9: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe
endif

.PHONY: l5j_25501419
l5j_25501419: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait.exe
endif

.PHONY: l5j_11BE9EC8
l5j_11BE9EC8: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe
endif

.PHONY: l5j_02A2A05C
l5j_02A2A05C: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe
endif

.PHONY: l5j_78CABE2B
l5j_78CABE2B: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_ED85B0DE
l5j_ED85B0DE: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped.exe
endif

.PHONY: l5j_853C1537
l5j_853C1537: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe
endif

.PHONY: l5j_F5506AE6
l5j_F5506AE6: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe
endif

.PHONY: l5j_5C448B7B
l5j_5C448B7B: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe
endif

.PHONY: l5j_895ED50D
l5j_895ED50D: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe
endif

.PHONY: l5j_39ABD48C
l5j_39ABD48C: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe
endif

.PHONY: l5j_38B963DC
l5j_38B963DC: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe
endif

.PHONY: l5j_092D167A
l5j_092D167A: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_07C35DAB
l5j_07C35DAB: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe
endif

.PHONY: l5j_D7AE1B5C
l5j_D7AE1B5C: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe
endif

.PHONY: l5j_61E6D532
l5j_61E6D532: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe
endif

.PHONY: l5j_2BD26F88
l5j_2BD26F88: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe
endif

.PHONY: l5j_36418169
l5j_36418169: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe
endif

.PHONY: l5j_80723D82
l5j_80723D82: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe
endif

.PHONY: l5j_2CD367E0
l5j_2CD367E0: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe
endif

.PHONY: l5j_B63A975C
l5j_B63A975C: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe
endif

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: all
all: \
  l5j_9F20B84D \
  l5j_6EB7DACE \
  l5j_F5B13FCD \
  l5j_4739563B \
  l5j_6E959748 \
  l5j_2E20373E \
  l5j_9FDC0678 \
  l5j_4CA6A4DC \
  l5j_F2F69A4A \
  l5j_D4F4011F \
  l5j_11C4FEF5 \
  l5j_6BE922C9 \
  l5j_25501419 \
  l5j_11BE9EC8 \
  l5j_02A2A05C \
  l5j_78CABE2B \
  l5j_ED85B0DE \
  l5j_853C1537 \
  l5j_F5506AE6 \
  l5j_5C448B7B \
  l5j_895ED50D \
  l5j_39ABD48C \
  l5j_38B963DC \
  l5j_092D167A \
  l5j_07C35DAB \
  l5j_D7AE1B5C \
  l5j_61E6D532 \
  l5j_2BD26F88 \
  l5j_36418169 \
  l5j_80723D82 \
  l5j_2CD367E0 \
  l5j_B63A975C


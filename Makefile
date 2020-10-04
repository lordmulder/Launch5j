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
LDFLAGS = -lcomctl32 -lgdi32

MANIFEST := tmp/assets/manifest.$(CPU_ARCH).xml

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

.PHONY: resources
resources: initialize $(MANIFEST)
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/common.$(CPU_ARCH).o res/common.rc
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/splash_screen.$(CPU_ARCH).o res/splash_screen.rc
	windres -DL5J_CPU_ARCH=$(CPU_ARCH) -DL5J_BUILDNO=$(BUILDNO) -o obj/registry.$(CPU_ARCH).o res/registry.rc

$(MANIFEST):
	mkdir -p $(@D)
	sed -e 's/$${{version}}/$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH).$(BUILDNO)/g' -e 's/$${{processorArchitecture}}/$(CPU_ARCH)/g' res/assets/manifest.xml > $@

.PHONY: clean
clean: initialize
	$(RM) bin/*.$(SUFFIX)
	$(RM) obj/*.o

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Binaries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: l5j_A7966B20
l5j_A7966B20: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH).exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH).exe
endif

.PHONY: l5j_32927420
l5j_32927420: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_noenc.exe
endif

.PHONY: l5j_C618EB78
l5j_C618EB78: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash.exe
endif

.PHONY: l5j_A517C52F
l5j_A517C52F: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe
endif

.PHONY: l5j_619D8B04
l5j_619D8B04: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait.exe
endif

.PHONY: l5j_30F743A4
l5j_30F743A4: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe
endif

.PHONY: l5j_82D827C0
l5j_82D827C0: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe
endif

.PHONY: l5j_1591EA3D
l5j_1591EA3D: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_C56C074D
l5j_C56C074D: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry.exe
endif

.PHONY: l5j_A832E835
l5j_A832E835: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_noenc.exe
endif

.PHONY: l5j_996B9E83
l5j_996B9E83: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe
endif

.PHONY: l5j_37546C69
l5j_37546C69: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe
endif

.PHONY: l5j_C9288BE6
l5j_C9288BE6: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait.exe
endif

.PHONY: l5j_7F3CC9AB
l5j_7F3CC9AB: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe
endif

.PHONY: l5j_459A8CE8
l5j_459A8CE8: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe
endif

.PHONY: l5j_ADC1141F
l5j_ADC1141F: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_00617FF8
l5j_00617FF8: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped.exe
endif

.PHONY: l5j_64929FEF
l5j_64929FEF: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe
endif

.PHONY: l5j_8E872293
l5j_8E872293: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe
endif

.PHONY: l5j_DDE02124
l5j_DDE02124: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe
endif

.PHONY: l5j_52A38734
l5j_52A38734: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe
endif

.PHONY: l5j_C5366010
l5j_C5366010: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe
endif

.PHONY: l5j_81C67748
l5j_81C67748: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe
endif

.PHONY: l5j_7F831D46
l5j_7F831D46: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_32A6D73F
l5j_32A6D73F: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe
endif

.PHONY: l5j_8B210991
l5j_8B210991: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe
endif

.PHONY: l5j_5959FDC1
l5j_5959FDC1: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe
endif

.PHONY: l5j_A3FE83BA
l5j_A3FE83BA: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe
endif

.PHONY: l5j_E830A8AE
l5j_E830A8AE: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe
endif

.PHONY: l5j_30C6BEB2
l5j_30C6BEB2: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe
endif

.PHONY: l5j_92CE9691
l5j_92CE9691: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe
endif

.PHONY: l5j_23E35141
l5j_23E35141: resources
	$(CC) $(CFLAGS) -mwindows -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=1 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_04319E4C
l5j_04319E4C: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli.exe
endif

.PHONY: l5j_0A4F96FD
l5j_0A4F96FD: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_noenc.exe
endif

.PHONY: l5j_9F7D329B
l5j_9F7D329B: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_nosplash.exe
endif

.PHONY: l5j_E924B9FC
l5j_E924B9FC: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_nosplash_noenc.exe
endif

.PHONY: l5j_5F6913C1
l5j_5F6913C1: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_nowait.exe
endif

.PHONY: l5j_AFC6A9C4
l5j_AFC6A9C4: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_nowait_noenc.exe
endif

.PHONY: l5j_B8C53EA8
l5j_B8C53EA8: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_nowait_nosplash.exe
endif

.PHONY: l5j_30E2A403
l5j_30E2A403: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_71295303
l5j_71295303: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_registry.exe
endif

.PHONY: l5j_7FD23D76
l5j_7FD23D76: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_registry_noenc.exe
endif

.PHONY: l5j_D013A919
l5j_D013A919: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_registry_nosplash.exe
endif

.PHONY: l5j_4E8A7105
l5j_4E8A7105: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_registry_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_registry_nosplash_noenc.exe
endif

.PHONY: l5j_DBD618F1
l5j_DBD618F1: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_registry_nowait.exe
endif

.PHONY: l5j_72C1D5DE
l5j_72C1D5DE: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_registry_nowait_noenc.exe
endif

.PHONY: l5j_9C2AFAAC
l5j_9C2AFAAC: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_registry_nowait_nosplash.exe
endif

.PHONY: l5j_4DD6F1C3
l5j_4DD6F1C3: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_registry_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_registry_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_3D436873
l5j_3D436873: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped.exe
endif

.PHONY: l5j_828B0AE9
l5j_828B0AE9: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_noenc.exe
endif

.PHONY: l5j_99D0F4B6
l5j_99D0F4B6: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_nosplash.exe
endif

.PHONY: l5j_32CF00DE
l5j_32CF00DE: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_nosplash_noenc.exe
endif

.PHONY: l5j_A4688080
l5j_A4688080: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_nowait.exe
endif

.PHONY: l5j_8F6F3F0E
l5j_8F6F3F0E: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_nowait_noenc.exe
endif

.PHONY: l5j_7F92D72F
l5j_7F92D72F: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_nowait_nosplash.exe
endif

.PHONY: l5j_0EE82CBC
l5j_0EE82CBC: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_083B5C46
l5j_083B5C46: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry.exe
endif

.PHONY: l5j_2ADF4293
l5j_2ADF4293: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_noenc.exe
endif

.PHONY: l5j_95F8BA11
l5j_95F8BA11: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nosplash.exe
endif

.PHONY: l5j_6F817826
l5j_6F817826: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nosplash_noenc.exe
endif

.PHONY: l5j_7959E22C
l5j_7959E22C: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nowait.exe
endif

.PHONY: l5j_AE9F1956
l5j_AE9F1956: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nowait_noenc.exe
endif

.PHONY: l5j_94E0873C
l5j_94E0873C: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nowait_nosplash.exe
endif

.PHONY: l5j_6FB4A82E
l5j_6FB4A82E: resources
	$(CC) $(CFLAGS) -mconsole -DL5J_BUILDNO=$(BUILDNO) -DL5J_ENABLE_GUI=0 -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_cli_wrapped_registry_nowait_nosplash_noenc.exe
endif

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: all
all: \
  l5j_A7966B20 \
  l5j_32927420 \
  l5j_C618EB78 \
  l5j_A517C52F \
  l5j_619D8B04 \
  l5j_30F743A4 \
  l5j_82D827C0 \
  l5j_1591EA3D \
  l5j_C56C074D \
  l5j_A832E835 \
  l5j_996B9E83 \
  l5j_37546C69 \
  l5j_C9288BE6 \
  l5j_7F3CC9AB \
  l5j_459A8CE8 \
  l5j_ADC1141F \
  l5j_00617FF8 \
  l5j_64929FEF \
  l5j_8E872293 \
  l5j_DDE02124 \
  l5j_52A38734 \
  l5j_C5366010 \
  l5j_81C67748 \
  l5j_7F831D46 \
  l5j_32A6D73F \
  l5j_8B210991 \
  l5j_5959FDC1 \
  l5j_A3FE83BA \
  l5j_E830A8AE \
  l5j_30C6BEB2 \
  l5j_92CE9691 \
  l5j_23E35141 \
  l5j_04319E4C \
  l5j_0A4F96FD \
  l5j_9F7D329B \
  l5j_E924B9FC \
  l5j_5F6913C1 \
  l5j_AFC6A9C4 \
  l5j_B8C53EA8 \
  l5j_30E2A403 \
  l5j_71295303 \
  l5j_7FD23D76 \
  l5j_D013A919 \
  l5j_4E8A7105 \
  l5j_DBD618F1 \
  l5j_72C1D5DE \
  l5j_9C2AFAAC \
  l5j_4DD6F1C3 \
  l5j_3D436873 \
  l5j_828B0AE9 \
  l5j_99D0F4B6 \
  l5j_32CF00DE \
  l5j_A4688080 \
  l5j_8F6F3F0E \
  l5j_7F92D72F \
  l5j_0EE82CBC \
  l5j_083B5C46 \
  l5j_2ADF4293 \
  l5j_95F8BA11 \
  l5j_6F817826 \
  l5j_7959E22C \
  l5j_AE9F1956 \
  l5j_94E0873C \
  l5j_6FB4A82E


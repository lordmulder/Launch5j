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
	windres -DL5J_BUILDNO=$(BUILDNO) -o obj/common.$(CPU_ARCH).o res/common.rc
	windres -DL5J_BUILDNO=$(BUILDNO) -o obj/splash_screen.$(CPU_ARCH).o res/splash_screen.rc
	windres -DL5J_BUILDNO=$(BUILDNO) -o obj/registry.$(CPU_ARCH).o res/registry.rc

.PHONY: clean
clean: init
	$(RM) bin/*.$(SUFFIX)
	$(RM) obj/*.o

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Binaries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: l5j_F9F9A1F5
l5j_F9F9A1F5: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH).exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH).exe
endif

.PHONY: l5j_387BDF25
l5j_387BDF25: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_noenc.exe
endif

.PHONY: l5j_31F684B4
l5j_31F684B4: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash.exe
endif

.PHONY: l5j_6A985F3B
l5j_6A985F3B: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nosplash_noenc.exe
endif

.PHONY: l5j_A813D876
l5j_A813D876: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait.exe
endif

.PHONY: l5j_F8EC1E57
l5j_F8EC1E57: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_noenc.exe
endif

.PHONY: l5j_5E261357
l5j_5E261357: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash.exe
endif

.PHONY: l5j_07A9F8CB
l5j_07A9F8CB: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_43E42BBF
l5j_43E42BBF: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry.exe
endif

.PHONY: l5j_0A5615A8
l5j_0A5615A8: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_noenc.exe
endif

.PHONY: l5j_6BF2F1D5
l5j_6BF2F1D5: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash.exe
endif

.PHONY: l5j_42DD17AD
l5j_42DD17AD: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nosplash_noenc.exe
endif

.PHONY: l5j_7C2731CC
l5j_7C2731CC: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait.exe
endif

.PHONY: l5j_A101EF16
l5j_A101EF16: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_noenc.exe
endif

.PHONY: l5j_7ADBDAB1
l5j_7ADBDAB1: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash.exe
endif

.PHONY: l5j_37115C1A
l5j_37115C1A: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=0 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_registry_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_44D8B4F3
l5j_44D8B4F3: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped.exe
endif

.PHONY: l5j_61D7AF7F
l5j_61D7AF7F: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_noenc.exe
endif

.PHONY: l5j_043C058B
l5j_043C058B: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash.exe
endif

.PHONY: l5j_614431D9
l5j_614431D9: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nosplash_noenc.exe
endif

.PHONY: l5j_DD3611A9
l5j_DD3611A9: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait.exe
endif

.PHONY: l5j_C267A006
l5j_C267A006: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_noenc.exe
endif

.PHONY: l5j_C15BE671
l5j_C15BE671: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash.exe
endif

.PHONY: l5j_E8DDCABF
l5j_E8DDCABF: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=0 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_nowait_nosplash_noenc.exe
endif

.PHONY: l5j_3645B652
l5j_3645B652: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry.exe
endif

.PHONY: l5j_45BDFACE
l5j_45BDFACE: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_noenc.exe
endif

.PHONY: l5j_C1FDBA19
l5j_C1FDBA19: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash.exe
endif

.PHONY: l5j_0DD7490D
l5j_0DD7490D: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=1 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nosplash_noenc.exe
endif

.PHONY: l5j_25375FF3
l5j_25375FF3: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait.exe
endif

.PHONY: l5j_988AA638
l5j_988AA638: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=1 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/splash_screen.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_noenc.exe
endif

.PHONY: l5j_939A7B9C
l5j_939A7B9C: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=1 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash.exe
endif

.PHONY: l5j_F2A93271
l5j_F2A93271: resources
	$(CC) $(CFLAGS) -DL5J_BUILDNO=$(BUILDNO) -DL5J_JAR_FILE_WRAPPED=1 -DL5J_DETECT_REGISTRY=1 -DL5J_STAY_ALIVE=0 -DL5J_ENABLE_SPLASH=0 -DL5J_ENCODE_ARGS=0 -o bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe src/head.c obj/common.$(CPU_ARCH).o obj/registry.$(CPU_ARCH).o $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip bin/launch5j_$(CPU_ARCH)_wrapped_registry_nowait_nosplash_noenc.exe
endif

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: all
all: \
  l5j_F9F9A1F5 \
  l5j_387BDF25 \
  l5j_31F684B4 \
  l5j_6A985F3B \
  l5j_A813D876 \
  l5j_F8EC1E57 \
  l5j_5E261357 \
  l5j_07A9F8CB \
  l5j_43E42BBF \
  l5j_0A5615A8 \
  l5j_6BF2F1D5 \
  l5j_42DD17AD \
  l5j_7C2731CC \
  l5j_A101EF16 \
  l5j_7ADBDAB1 \
  l5j_37115C1A \
  l5j_44D8B4F3 \
  l5j_61D7AF7F \
  l5j_043C058B \
  l5j_614431D9 \
  l5j_DD3611A9 \
  l5j_C267A006 \
  l5j_C15BE671 \
  l5j_E8DDCABF \
  l5j_3645B652 \
  l5j_45BDFACE \
  l5j_C1FDBA19 \
  l5j_0DD7490D \
  l5j_25375FF3 \
  l5j_988AA638 \
  l5j_939A7B9C \
  l5j_F2A93271


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

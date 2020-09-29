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

ifeq ($(words $(filter x86_64-%,$(shell $(CXX) -dumpmachine))),0)
  CPU_ARCH := i586
else
  CPU_ARCH := x86-64
endif

MARCH ?= $(CPU_ARCH)
MTUNE ?= generic

CFLAGS = -Os -static -municode -mwindows -march=$(MARCH) -mtune=$(MTUNE)

.PHONY: all init resources build strip clean

all: strip

init:
	mkdir -p bin
	mkdir -p obj

resources: init
	windres -o obj/common.$(CPU_ARCH).o res/common.rc
	windres -o obj/splash_screen.$(CPU_ARCH).o res/splash_screen.rc
	windres -o obj/registry.$(CPU_ARCH).o res/registry.rc

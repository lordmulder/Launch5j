/************************************************************/
/* Launch5j, by LoRd_MuldeR <MuldeR2@GMX.de>                */
/* Java JAR wrapper for creating Windows native executables */
/* https://github.com/lordmulder/                           */
/*                                                          */
/* This work has been released under the MIT license.       */
/* Please see LICENSE.TXT for details!                      */
/*                                                          */
/* ACKNOWLEDGEMENT                                          */
/* This project is partly inspired by the Launch4j project: */
/* https://sourceforge.net/p/launch4j/                      */
/************************************************************/

#ifndef L5J_RESOURCE_H
#define L5J_RESOURCE_H

// BUILD NO
#ifndef L5J_BUILDNO
#error  L5J_BUILDNO is not defined!
#endif

// VERSION
#define L5J_VERSION_MAJOR 0
#define L5J_VERSION_MINOR 8
#define L5J_VERSION_PATCH 0

// ICON
#define ID_ICON_MAIN 1

// BITMAP
#define ID_BITMAP_SPLASH 1

// STRINGS
#define ID_STR_HEADING 0x1
#define ID_STR_JVMARGS 0x2
#define ID_STR_CMDARGS 0x3
#define ID_STR_JREPATH 0x4
#define ID_STR_MUTEXID 0x5
#define ID_STR_HEAPMIN 0x6
#define ID_STR_HEAPMAX 0x7
#define ID_STR_JAVAMIN 0x8
#define ID_STR_JAVAMAX 0x9
#define ID_STR_BITNESS 0xA
#define ID_STR_JAVAURL 0xB

#endif

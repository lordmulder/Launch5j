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

import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/*
 * Helper program to generate the Makefile rules for Launch5j
 */
public class MakefileGenerator {

    public static void main(String[] args) throws UnsupportedEncodingException {
        final List<String> filenNames = new ArrayList<String>();
        final PrintStream out = new PrintStream(System.out, true, StandardCharsets.UTF_8.name());
        
        out.println("build: init resources"); 
        for(int wrapped = 0; wrapped < 2; ++wrapped) {
            for(int registry = 0; registry < 2; ++registry) {
                for(int requireJava = 8; requireJava < 12; ++requireJava) {
                    if(requireJava == 10) {
                        continue;
                    }
                    for(int requireBitness = 0; requireBitness < 65; requireBitness += 32) {
                        for(int stayAlive = 1; stayAlive > -1; --stayAlive) {
                            for(int enableSplash = 1; enableSplash > -1; --enableSplash) {
                                if((registry == 0) && ((requireJava != 8) || (requireBitness != 0))) {
                                    continue;
                                }
                                out.println(generate(filenNames, wrapped, registry, requireJava, requireBitness, stayAlive, enableSplash));
                            }
                        }
                    }
                }
            }
        }
        
        out.println("\nstrip: build");
        for(final String fileName : filenNames) {
            out.printf("\tstrip %s\n", fileName);
        }
    }

    private static String generate(final List<String> filenNames, final int wrapped, final int registry, final int requireJava, final int requireBitness, final int stayAlive, final int enableSplash)
    {
        final String fileName = String.format("bin/launch5j_$(CPU_ARCH)%s.exe", 
                generateNameSuffix(wrapped, registry, requireJava, requireBitness, stayAlive, enableSplash));
        final StringBuilder cmdLine = new StringBuilder(String.format(
                "\t$(CC) $(CFLAGS) "
                    + "-DJAR_FILE_WRAPPED=%d "
                    + "-DDETECT_REGISTRY=%d "
                    + "-DREQUIRE_JAVA=%-2d "
                    + "-DREQUIRE_BITNESS=%-2d "
                    + "-DSTAY_ALIVE=%d "
                    + "-DENABLE_SPLASH=%d "
                    + "-o %s "
                    + "src/head.c obj/version.$(CPU_ARCH).o obj/icon.$(CPU_ARCH).o",
                wrapped,
                registry,
                requireJava,
                requireBitness,
                stayAlive,
                enableSplash,
                fileName));
        
        if(enableSplash > 0) {
            append(cmdLine, ' ', " obj/splash_screen.$(CPU_ARCH).o");
        }
        
        filenNames.add(fileName);
        return cmdLine.toString();
    }

    private static String generateNameSuffix(final int wrapped, final int registry, final int requireJava, final int requireBitness, final int stayAlive, final int enableSplash) {
        final StringBuilder builder = new StringBuilder();
        if(wrapped > 0) {
            append(builder, '_', "wrapped");
        }
        if(registry > 0) {
            append(builder, '_', "registry");
        }
        if(requireJava != 8) {
            append(builder, '_', String.format("java%d", requireJava));
        }
        if(requireBitness != 0) {
            append(builder, '_', String.format("only%dbit", requireBitness));
        }
        if(stayAlive == 0) {
            append(builder, '_', "nowait");
        }
        if(enableSplash == 0) {
            append(builder, '_', "nosplash");
        }
        return (builder.length() > 0) ? builder.insert(0, '_').toString() : "";
    }

    private static void append(final StringBuilder builder, final char sep, final String string) {
        if(builder.length() != 0) {
            builder.append(sep);
        }
        builder.append(string);
    }

}

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

package com.muldersoft.l5j.makefile;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/*
 * Helper program to generate the Makefile rules for Launch5j
 */
public class Generator {

    private final static String EMPTY = "";
    private final static Pattern RTRIM = Pattern.compile("\\s+$");

    public static void main(String[] args) throws IOException {
        final List<String> targets = new ArrayList<String>();
        final PrintStream out = new PrintStream(System.out, true, StandardCharsets.UTF_8.name());

        outputTemplate(out, "header");

        for (int wrapped = 0; wrapped < 2; ++wrapped) {
            for (int registry = 0; registry < 2; ++registry) {
                for (int stayAlive = 1; stayAlive > -1; --stayAlive) {
                    for (int enableSplash = 1; enableSplash > -1; --enableSplash) {
                        for (int encArgs = 1; encArgs > -1; --encArgs) {
                            out.println(generateCommand(targets, wrapped, registry, stayAlive, enableSplash, encArgs));
                        }
                    }
                }
            }
        }

        out.println("# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        out.println("# ALL");
        out.println("# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        out.println();
        
        out.println(".PHONY: all");
        out.print("all:");
        for(final String target: targets) { 
            out.printf(" \\\n  %s", target);
        }
        out.println("\n");
    }

    private static void outputTemplate(final PrintStream out, final String name) throws IOException {
        try (final InputStream in = Generator.class.getResourceAsStream(String.format("/.assets/templates/%s.mak", name))) {
            if (in == null) {
                throw new IOException("Failed to open '" + name + "' template file!");
            }
            try (final BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
                boolean blank = false, first = true;
                String line;
                while ((line = reader.readLine()) != null) {
                    line = RTRIM.matcher(line).replaceAll(EMPTY);
                    if (line.isEmpty()) {
                        blank = true;
                        continue;
                    }
                    if (blank) {
                        if (!first) {
                            out.println();
                        }
                        blank = false;
                    }
                    out.println(line);
                    first = false;
                }
            }
        }
        out.println();
    }

    private static String generateCommand(final List<String> targets, final int wrapped, final int registry, final int stayAlive, final int enableSplash, final int encArgs) {
        final String nameSuffix = generateNameSuffix(wrapped, registry, stayAlive, enableSplash, encArgs);
        final String targetName = "l5j" + nameSuffix;
        targets.add(targetName);
        final StringBuilder cmdLine = new StringBuilder();
        cmdLine.append(String.format(".PHONY: %s\n", targetName));
        cmdLine.append(String.format("%s: resources\n", targetName));
        cmdLine.append(String.format("\t$(CC) $(CFLAGS) " +
                        "-DL5J_JAR_FILE_WRAPPED=%d " +
                        "-DL5J_DETECT_REGISTRY=%d " +
                        "-DL5J_STAY_ALIVE=%d " +
                        "-DL5J_ENABLE_SPLASH=%d " +
                        "-DL5J_ENCODE_ARGS=%d " +
                        "-o bin/launch5j_$(CPU_ARCH)%s.exe " +
                        "src/head.c obj/common.$(CPU_ARCH).o",
                        wrapped,
                        registry,
                        stayAlive,
                        enableSplash,
                        encArgs,
                        nameSuffix));
        if (enableSplash > 0) {
            cmdLine.append(" obj/splash_screen.$(CPU_ARCH).o");
        }
        if (registry > 0) {
            cmdLine.append(" obj/registry.$(CPU_ARCH).o");
        }
        cmdLine.append(" $(LDFLAGS)\n");
        cmdLine.append("ifeq ($(DEBUG),0)\n");
        cmdLine.append(String.format("\tstrip bin/launch5j_$(CPU_ARCH)%s.exe\n", nameSuffix));
        cmdLine.append("endif\n");
        return cmdLine.toString();
    }

    private static String generateNameSuffix(final int wrapped, final int registry, final int stayAlive, final int enableSplash, final int encArgs) {
        final StringBuilder builder = new StringBuilder();
        if (wrapped > 0) {
            append(builder, '_', "wrapped");
        }
        if (registry > 0) {
            append(builder, '_', "registry");
        }
        if (stayAlive == 0) {
            append(builder, '_', "nowait");
        }
        if (enableSplash == 0) {
            append(builder, '_', "nosplash");
        }
        if (encArgs == 0) {
            append(builder, '_', "noenc");
        }
        return (builder.length() > 0) ? builder.insert(0, '_').toString() : "";
    }

    private static void append(final StringBuilder builder, final char sep, final String string) {
        if (builder.length() != 0) {
            builder.append(sep);
        }
        builder.append(string);
    }

}

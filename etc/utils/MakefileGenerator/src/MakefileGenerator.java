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
public class MakefileGenerator {

    private final static String EMPTY = "";
    private final static Pattern RTRIM = Pattern.compile("\\s+$");
    
    public static void main(String[] args) throws IOException {
        final List<String> filenNames = new ArrayList<String>();
        final PrintStream out = new PrintStream(System.out, true, StandardCharsets.UTF_8.name());

        outputTemplate(out, "header");
        
        out.println("build: init resources"); 
        for(int wrapped = 0; wrapped < 2; ++wrapped) {
            for(int registry = 0; registry < 2; ++registry) {
                for(int stayAlive = 1; stayAlive > -1; --stayAlive) {
                    for(int enableSplash = 1; enableSplash > -1; --enableSplash) {
                        out.println(generateCommand(filenNames, wrapped, registry, stayAlive, enableSplash));
                    }
                }
            }
        }
        
        out.println("\nstrip: build");
        for(final String fileName : filenNames) {
            out.printf("\tstrip %s\n", fileName);
        }
        
        out.println();
        outputTemplate(out, "footer");
    }

    private static void outputTemplate(final PrintStream out, final String name) throws IOException {
        try(final InputStream in = MakefileGenerator.class.getResourceAsStream(String.format("/templates/%s.mak", name))) {
            if(in == null) {
                throw new IOException("Failed to open '" + name + "' template file!");
            }
            try(final BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
                boolean blank = false, first = true;
                String line;
                while((line = reader.readLine()) != null) {
                    line = RTRIM.matcher(line).replaceAll(EMPTY);
                    if(line.isEmpty()) {
                        blank = true;
                        continue;
                    }
                    if(blank) {
                        if(!first) {
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

    private static String generateCommand(final List<String> filenNames, final int wrapped, final int registry, final int stayAlive, final int enableSplash)
    {
        final String fileName = String.format("bin/launch5j_$(CPU_ARCH)%s.exe", 
                generateNameSuffix(wrapped, registry, stayAlive, enableSplash));
        final StringBuilder cmdLine = new StringBuilder(String.format(
                "\t$(CC) $(CFLAGS) "
                    + "-DJAR_FILE_WRAPPED=%d "
                    + "-DDETECT_REGISTRY=%d "
                    + "-DSTAY_ALIVE=%d "
                    + "-DENABLE_SPLASH=%d "
                    + "-o %s "
                    + "src/head.c obj/common.$(CPU_ARCH).o",
                wrapped,
                registry,
                stayAlive,
                enableSplash,
                fileName));
        
        if(enableSplash > 0) {
            append(cmdLine, ' ', "obj/splash_screen.$(CPU_ARCH).o");
        }
        if(registry > 0) {
            append(cmdLine, ' ', "obj/registry.$(CPU_ARCH).o");
        }
        
        filenNames.add(fileName);
        return cmdLine.toString();
    }

    private static String generateNameSuffix(final int wrapped, final int registry, final int stayAlive, final int enableSplash) {
        final StringBuilder builder = new StringBuilder();
        if(wrapped > 0) {
            append(builder, '_', "wrapped");
        }
        if(registry > 0) {
            append(builder, '_', "registry");
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

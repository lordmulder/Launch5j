/************************************************************/
/* Launch5j, by LoRd_MuldeR <MuldeR2@GMX.de>                */
/* Java JAR wrapper for creating Windows native executables */
/* https://github.com/lordmulder/                           */
/*                                                          */
/* The sample code in this file has been released under the */
/* CC0 1.0 Universal license.                               */
/* https://creativecommons.org/publicdomain/zero/1.0/       */
/************************************************************/

package com.muldersoft.l5j.example;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.regex.Pattern;

import javax.swing.JOptionPane;

public class Main {
    public static void main(final String[] args) {
        initCommandlineArgs(args);
        final String message = String.format(
                "Hello world!\nRunning on Java %s\n\nCommand-line args:\n%s",
                System.getProperty("java.version", "(unknown)"),
                dumpCommandLine(args));
        JOptionPane.showMessageDialog(null, message, "Launch5j", JOptionPane.INFORMATION_MESSAGE);
    }

    private static void initCommandlineArgs(final String[] argv) {
        if (System.getProperty("l5j.pid") == null) {
            return; /*nothing to do*/
        }
        final String enc = StandardCharsets.UTF_8.name();
        for (int i = 0; i < argv.length; ++i) {
            try {
                argv[i] = URLDecoder.decode(argv[i], enc);
            } catch (Exception e) { }
        }
    }

    private static String dumpCommandLine(final String[] argv) {
        final StringBuilder sb = new StringBuilder();
        final Pattern pattern = Pattern.compile(Pattern.quote("\""));
        int argc = 0;
        for (final String str : argv) {
            sb.append(String.format(
                    needQuotes(str) ? "argv[%d] = \"%s\"\n" : "argv[%d] = %s\n",
                    argc++, pattern.matcher(str).replaceAll("\\\\\"")));
        }
        return (sb.length() > 0) ? sb.toString() : "(none)";
    }
    
    private static boolean needQuotes(final String arg) {
        if((arg == null) || arg.isEmpty()) {
            return true;
        }
        for (int i = 0; i < arg.length(); ++i) {
            if (Character.isSpaceChar(arg.charAt(i))) {
                return true;
            }
        }
        return false;
    }
}
